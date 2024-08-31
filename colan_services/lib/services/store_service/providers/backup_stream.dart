import 'dart:async';
import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/store_backup.dart';
import '../models/store_manager.dart';

final backupNowProvider =
    StreamProvider.family<Progress, StoreManager>((ref, storeManager) async* {
  final controller = StreamController<Progress>();

  ref.listen(backupFileProvider, (prev, backupFileName) async {
    if (prev != backupFileName && backupFileName != null) {
      await storeManager.backup(
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
