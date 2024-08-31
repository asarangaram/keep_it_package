// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:colan_services/services/store_service/models/store_manager.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';
import 'package:tar/tar.dart';

extension BackupExtOnStoreManager on StoreManager {
  Future<String> backup({
    required File output,
    required void Function(Progress progress) onData,
    VoidCallback? onDone,
  }) async {
    final query = store.getQuery<CLMedia>(DBQueries.mediaAllIncludingAux);
    final mediaList = (await store.readMultiple(query))
        .where((e) => e != null)
        .map((e) => e!)
        .toList();
    if (mediaList.isEmpty) return '';

    final archive = <Map<String, dynamic>>[];
    final files = <String>[];

    for (final media in mediaList) {
      final localPath = getMediaFileName(media);
      // Archive only if files are present locally.
      // We may also exclude items that are already present in server.

      if (File(localPath).existsSync()) {
        final map = media.toMap();
        final notesQuery = store.getQuery<CLMedia>(
          DBQueries.notesByMediaId,
          parameters: [media.id],
        );
        final collectionQuery = store.getQuery<Collection>(
          DBQueries.collectionById,
          parameters: [media.collectionId],
        );
        map['notes'] = await store.readMultiple(notesQuery);
        map['collectionLabel'] = (await store.read(collectionQuery))?.label;
        map.remove('collectionId');
        map['path'] = localPath;
        files.add(localPath);

        archive.add(map);
      }
    }

    if (archive.isEmpty) return '';

    final indexData = json.encode(archive);

    final totalFiles = files.length;
    var processedFiles = 0;

    await streamTagEntries(
      indexData,
      files,
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
    List<String> mediaFiles, {
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
      final entry = MapEntry(p.basename(mediaFile), File(mediaFile));
      onData(entry);
      yield entry2tarEntry(entry);
      await Future<void>.delayed(const Duration(milliseconds: 1000));
    }
    print('done');
    onDone?.call();
  }
}
