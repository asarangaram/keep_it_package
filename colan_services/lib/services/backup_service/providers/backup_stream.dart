import 'dart:async';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../settings_service/providers/p1_app_settings.dart';
import '../../store_service/models/store_manager.dart';
import '../models/backup_files.dart';

final backupNowProvider =
    StreamProvider.family<Progress, StoreManager>((ref, storeManager) async* {
  final controller = StreamController<Progress>();

  final appSettings = await ref.watch(appSettingsProvider.future);
  final storeInstance = storeManager.store;

  ref.listen(backupFileProvider, (prev, backupFileName) async {
    if (prev != backupFileName && backupFileName != null) {
      final backupManager = BackupManager(
        storeInstance: storeInstance,
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
