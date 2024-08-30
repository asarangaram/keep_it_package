// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';
import 'package:tar/tar.dart';

import '../../settings_service/models/m1_app_settings.dart';
import 'files.dart';

class BackupManager {
  AppSettings appSettings;
  Store storeInstance;

  BackupManager({
    required this.appSettings,
    required this.storeInstance,
  });

  Future<String> backup({
    required File output,
    required void Function(Progress progress) onData,
    VoidCallback? onDone,
  }) async {
    final dbArchive = await storeInstance.getDBRecords();
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
                  appSettings.directories.media.pathString,
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
