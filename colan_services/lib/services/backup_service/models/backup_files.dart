// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';
import 'package:tar/tar.dart';

class BackupManager {
  List<Directory> directories;
  Directory baseDir;

  BackupManager({
    required this.directories,
    required this.baseDir,
  });

  static File backupFile(Directory directory) {
    final now = DateTime.now();
    final name = DateFormat('yyyyMMdd_HHmmss_SSS').format(now);
    return File(p.join(directory.path, 'keep_it_$name.tar.gz'));
  }

  Stream<Progress> backupStream({
    required File output,
    required void Function(String backupFile) onDone,
  }) async* {
    final controller = StreamController<Progress>();

    unawaited(
      backup(
        output: output,
        onData: controller.add,
        onDone: () => onDone(output.path),
      ),
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

final backupNowProvider = StreamProvider<Progress>((ref) async* {
  final controller = StreamController<Progress>();
  final appSettings = await ref.watch(appSettingsProvider.future);

  ref.listen(refreshProvider, (prev, curr) async {
    if (prev != curr && curr != 0) {
      final directories = CLStandardDirectories.values
          .where((stddir) => stddir.isStore)
          .map(appSettings.directories.standardDirectory)
          .toList();
      final backupManager = BackupManager(
        directories: directories.map((e) => e.path).toList(),
        baseDir: appSettings.directories.persistent,
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
