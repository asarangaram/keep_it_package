// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:tar/tar.dart';

class BackupManager {
  List<Directory> directories;
  Directory baseDir;
  Directory backupFolder;
  BackupManager({
    required this.directories,
    required this.baseDir,
    required this.backupFolder,
  });

  File backupFile() {
    final now = DateTime.now();
    final name = DateFormat('yyyyMMdd_HHmmss_SSS').format(now);
    return File(p.join(backupFolder.path, 'keep_it_$name.tar.gz'));
  }

  Stream<Progress> backupStream({
    required void Function(String backupFile) onDone,
  }) async* {
    final controller = StreamController<Progress>();
    final output = backupFile();
    unawaited(
      backup(
        output: output,
        onData: controller.add,
        onDone: () => onDone(output.path),
      ).then(onDone),
    );
    yield* controller.stream;
  }

  Future<String> backup({
    required File output,
    required void Function(Progress progress) onData,
    VoidCallback? onDone,
  }) async {
    final totalFiles = directories.fold(
      0,
      (previousValue, element) => previousValue + (element.fileCount()),
    );
    var processedFiles = 0;

    final streamOfFiles = tee<MapEntry<String, File>>(findFiles(), 2);
    streamOfFiles[1].listen(
      (entry) {
        processedFiles++;
        onData(
          Progress(
            fractCompleted: processedFiles / totalFiles,
            currentItem: entry.key,
          ),
        );
      },
      onDone: onDone,
    );

    await streamTagEntries(streamOfFiles[0])
        .transform(tarWriter)
        .transform(gzip.encoder)
        .pipe(output.openWrite());
    return output.path;
  }

  Stream<MapEntry<String, File>> findFiles() async* {
    for (final directory in directories) {
      await for (final entry in directory.list(recursive: true)) {
        if (entry is! File) continue;
        final name = p.relative(entry.path, from: baseDir.path);
        if (name.startsWith('.')) continue;
        await Future<void>.delayed(const Duration(seconds: 1));
        yield MapEntry(name, entry);
      }
    }
  }

  List<Stream<T>> tee<T>(Stream<T> inputStream, int count) {
    final controllers = List<StreamController<T>>.generate(
      count,
      (_) => StreamController<T>.broadcast(),
    );

    inputStream.listen(
      (data) {
        for (final controller in controllers) {
          controller.add(data);
        }
      },
      onError: (Object error) {
        for (final controller in controllers) {
          controller.addError(error);
        }
      },
      onDone: () {
        for (final controller in controllers) {
          controller.close();
        }
      },
    );

    return controllers.map((controller) => controller.stream).toList();
  }

  Stream<TarEntry> streamTagEntries(
    Stream<MapEntry<String, File>> filesStream,
  ) async* {
    final controller = StreamController<TarEntry>();

    filesStream.listen((entry) {
      final name = entry.key;
      final file = entry.value;
      final stat = file.statSync();

      controller.add(
        TarEntry(
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
        ),
      );
    });
    yield* controller.stream;
  }
}
