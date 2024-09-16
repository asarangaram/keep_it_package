import 'dart:async';

import 'package:background_downloader/background_downloader.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class Downloader {
  Downloader({this.maxConcurrentTasks = 2}) {
    fileDownloader = FileDownloader()..trackTasks();
    FileDownloader().updates.listen((update) {
      fileDownloader.database.allRecords().then((records) {
        runningTasksStreamController.add(
          records.where((e) => e.status == TaskStatus.running).toList(),
        );
      });

      final handler = downloads[update.task.taskId];

      switch (update) {
        case TaskStatusUpdate():
          switch (update.status) {
            case TaskStatus.complete:
              handler?.call();
            case TaskStatus.failed:
              handler?.call(errorLog: update.responseBody ?? 'Unknown Error');
            case TaskStatus.canceled:
              handler?.call(errorLog: 'Download cancelled, try again');
            case TaskStatus.running:
            case TaskStatus.enqueued:
            case TaskStatus.notFound:
            case TaskStatus.paused:
            case TaskStatus.waitingToRetry:
              break;
          }

        case TaskProgressUpdate():
          break;
      }
    });
  }

  final int maxConcurrentTasks;
  late final FileDownloader fileDownloader;
  final downloads = <String, Future<void> Function({String? errorLog})?>{};
  final runningTasksStreamController = StreamController<List<TaskRecord>>();

  Future<bool> enqueue({
    required String url,
    required BaseDirectory baseDirectory,
    required String directory,
    required String filename,
    Future<void> Function({String? errorLog})? onDone,
    String group = 'Unclassified',
  }) async {
    final task = DownloadTask(
      url: url,
      filename: filename,
      directory: directory,
      baseDirectory: baseDirectory,
      group: group,
    );

    downloads[task.taskId] = onDone;

    return fileDownloader.enqueue(task);
  }

  Future<void> removeCompleted() async {
    final records = await fileDownloader.database.allRecords();

    downloads.removeWhere((key, value) {
      return records.where((e) => e.taskId == key).firstOrNull?.status ==
          TaskStatus.complete;
    });
  }

  void dispose() {
    runningTasksStreamController.close();
  }
}

final downloaderProvider = Provider<Downloader>((ref) {
  final downloader = Downloader();
  ref.onDispose(downloader.dispose);
  return downloader;
});

final runningTasksProvider = StreamProvider<List<TaskRecord>>(
  (ref) async* {
    yield* ref.watch(downloaderProvider).runningTasksStreamController.stream;
  },
);
