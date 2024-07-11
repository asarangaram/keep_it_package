import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/p1_app_settings.dart';
import 'storage_statistics.dart';

final backupFileProvider = StreamProvider<FileSystemEntity?>((ref) async* {
  final appSettings = await ref.read(appSettingsProvider.future);
  final controller = StreamController<FileSystemEntity?>();
  controller.add(appSettings.directories.backup.path.listSync().firstOrNull);

  // Watch for changes.
  final stats =
      ref.watch(storageStatisticsProvider(appSettings.directories.backup.path));

  stats.whenData((data) {
    controller.add(appSettings.directories.backup.path.listSync().firstOrNull);
  });

  yield* controller.stream;
});
