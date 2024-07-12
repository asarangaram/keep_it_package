import 'dart:async';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/backup_files.dart';

final backupNowProvider = StreamProvider<Progress>((ref) async* {
  final controller = StreamController<Progress>();
  final appSettings = await ref.watch(appSettingsProvider.future);
  final dbManager = await GetStore.getHandle(ref);

  ref.listen(backupFileProvider, (prev, backupFileName) async {
    if (prev != backupFileName && backupFileName != null) {
      final backupManager = BackupManager(
        dbManager: dbManager,
        appSettings: appSettings,
      );

      await backupManager.backup(
        output: File(backupFileName),
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

final backupFileProvider = StateProvider<String?>((ref) => null);
