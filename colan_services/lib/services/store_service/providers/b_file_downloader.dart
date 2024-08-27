import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'store.dart';

final fileDownloaderProvider = StateProvider<FileDownloader>((ref) {
  final futureStore = ref.watch(storeProvider.future);
  final fileDownloader = FileDownloader()
    ..updates.listen((update) {
      switch (update) {
        case TaskStatusUpdate():
          switch (update.status) {
            case TaskStatus.complete:

              /// From metadata, obtaion what we are downloading and update
              /// the db appropriately
              //print('Task ${update.task.taskId} success!');
              futureStore.then<void>((store) {
                // Update metadata in store
              });
            //ref.invalidate() appropriate metadata

            case TaskStatus.canceled:
            case TaskStatus.paused:
            case TaskStatus.enqueued:
            case TaskStatus.running:
            case TaskStatus.notFound:
            case TaskStatus.failed:
            case TaskStatus.waitingToRetry:
              break;
          }

        case TaskProgressUpdate():
          break;
      }
    });
  return fileDownloader;
});
