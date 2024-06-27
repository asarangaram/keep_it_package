// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';
import 'package:tar/tar.dart';

import 'files.dart';

class BackupManager {
  AppSettings appSettings;
  DBManager dbManager;

  BackupManager({
    required this.appSettings,
    required this.dbManager,
  });

  static File backupFile(Directory directory) {
    final now = DateTime.now();
    final name = DateFormat('yyyyMMdd_HHmmss_SSS').format(now);
    return File(p.join(directory.path, 'keep_it_$name.tar.gz'));
  }

  Future<String> backup({
    required File output,
    required void Function(Progress progress) onData,
    VoidCallback? onDone,
  }) async {
    final dbArchive = await dbManager.rawQuery(backupQuery);
    if (dbArchive == null || dbArchive.isEmpty) return '';

    final indexData = json.encode(dbArchive);
    

    final mediaFiles = await gatherFiles(dbArchive);
    final totalFiles = mediaFiles.fold(
      0,
      (previousValue, element) => previousValue + element.filesCount,
    );
    var processedFiles = 0;

    await streamTagEntries(
      indexData,
      mediaFiles,
      onData: (entry) {
        processedFiles++;

        onData(
          Progress(
            fractCompleted: processedFiles / totalFiles,
            currentItem: entry.key,
          ),
        );
      },
      onDone: onDone,
    ).transform(tarWriter).transform(gzip.encoder).pipe(output.openWrite());

    return output.path;
  }

  TarEntry entry2tarEntry(MapEntry<String, File> entry) {
    final name = entry.key;
    final file = entry.value;
    final stat = file.statSync();
    final tarEntry = TarEntry(
      TarHeader(
        name: name,
        typeFlag: TypeFlag.reg,
        mode: stat.mode,
        modified: stat.modified,
        accessed: stat.accessed,
        changed: stat.changed,
        size: stat.size,
      ),
      file.openRead(),
    );
    return tarEntry;
  }

  Stream<TarEntry> streamTagEntries(
    String indexData,
    List<MediaFile> mediaFiles, {
    required void Function(MapEntry<String, File> entry) onData,
    VoidCallback? onDone,
  }) async* {
    yield TarEntry.data(
      TarHeader(
        name: 'index.json',
        mode: int.parse('644', radix: 8),
      ),
      utf8.encode(indexData),
    );

    for (final mediaFile in mediaFiles) {
      onData(mediaFile.mapEntry);
      yield entry2tarEntry(mediaFile.mapEntry);
      if ((mediaFile.noteFiles?.length ?? 0) > 0) {
        for (final noteFile in mediaFile.noteFiles!) {
          onData(mediaFile.mapEntry);
          yield entry2tarEntry(noteFile.mapEntry);
        }
      }
    }
    onDone?.call();
  }

  Future<List<MediaFile>> gatherFiles(List<Object?> dbArchive) async {
    final fileEntries = <MediaFile>[];
    for (final media in dbArchive) {
      if (media != null) {
        final e = jsonDecode(media as String);
        final mediaMap = Map<String, dynamic>.from(e as Map<dynamic, dynamic>);
        final file = mediaMap['itemPath'] as String;
        if (file.isNotEmpty) {
          final absPath =
              p.join(appSettings.directories.media.pathString, file);
          if (File(absPath).existsSync()) {
            var mediaFile = MediaFile(path: file, absPath: absPath);

            if ((mediaMap['notes'] as dynamic).runtimeType == List) {
              final noteFiles = <NotesFile>[];
              // We have notes
              for (final n in mediaMap['notes'] as List) {
                final note =
                    Map<String, dynamic>.from(n as Map<dynamic, dynamic>);

                final notePath = note['notePath'] as String;
                final noteAbsPath = p.join(
                  appSettings.directories.notes.pathString,
                  notePath,
                );

                if (File(noteAbsPath).existsSync()) {
                  final noteFile =
                      NotesFile(path: notePath, absPath: noteAbsPath);
                  noteFiles.add(noteFile);
                }
              }
              mediaFile = mediaFile.copyWith(noteFiles: noteFiles);
            }
            fileEntries.add(mediaFile);
          }
        }
      }
    }
    return fileEntries;
  }
}

final backupNowProvider = StreamProvider<Progress>((ref) async* {
  final controller = StreamController<Progress>();
  final appSettings = await ref.watch(appSettingsProvider.future);
  final dbManager = await ref.watch(dbManagerProvider.future);

  ref.listen(refreshProvider, (prev, curr) async {
    if (prev != curr && curr != 0) {
      final backupManager = BackupManager(
        dbManager: dbManager,
        appSettings: appSettings,
      );
      final file = BackupManager.backupFile(
        appSettings.directories.backup.path,
      );
      appSettings.directories.backup.path.clear();

      await backupManager.backup(
        output: file,
        onData: controller.add,
        onDone: () {
          controller.add(
            const Progress(
              fractCompleted: 1,
              currentItem: 'Completed',
              isDone: true,
            ),
          );
        },
      );
    }
  });
  controller.add(
    const Progress(
      fractCompleted: 1,
      currentItem: 'Completed',
      isDone: true,
    ),
  );

  yield* controller.stream;
});

final refreshProvider = StateProvider<int>((ref) => 0);

const backupQuery = '''
SELECT 
    json_object(
        'itemId', Item.id,
        'itemPath', Item.path,
        'itemRef', Item.ref,
        'collectionLabel', Collection.label,
        'itemType', Item.type,
        'itemMd5String', Item.md5String,
        'itemOriginalDate', Item.originalDate,
        'itemCreatedDate', Item.createdDate,
        'itemUpdatedDate', Item.updatedDate,
         'notes',
        CASE 
            WHEN EXISTS (
                SELECT 1 
                FROM ItemNote 
                WHERE ItemNote.itemId = Item.id
            )
            THEN  json_group_array(
                    json_object(
                        'notePath', Notes.path,
                        'noteType', Notes.type
                    ))
                
           
        END 
    ) 
FROM 
    Item
LEFT JOIN 
    Collection ON Item.collectionId = Collection.id
LEFT JOIN 
    ItemNote ON Item.id = ItemNote.itemId
LEFT JOIN 
    Notes ON ItemNote.noteId = Notes.id
GROUP BY
    Item.id;
''';
