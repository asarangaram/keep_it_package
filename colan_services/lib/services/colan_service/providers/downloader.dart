// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/downloader_status.dart';

extension StatisticsExtOnTaskStatus on TaskStatus {
  bool get isWaiting => [
        TaskStatus.enqueued,
        TaskStatus.waitingToRetry,
        TaskStatus.paused,
      ].contains(this);
  bool get isRunning => this == TaskStatus.running;
  bool get isCompleted => [
        TaskStatus.complete,
        TaskStatus.failed,
        TaskStatus.canceled,
      ].contains(this);
  bool get isUnknown => this == TaskStatus.notFound;
}

class Downloader {
  Downloader() {
    fileDownloader = FileDownloader();
    FileDownloader().updates.listen((update) {
      switch (update) {
        case TaskStatusUpdate():
          statusMap[update.task.taskId] = update.status;
          var status = DownloaderStatus(
            unknown: statusMap.values.where((e) => e.isUnknown).length,
            running: statusMap.values.where((e) => e.isRunning).length,
            waiting: statusMap.values.where((e) => e.isWaiting).length,
            completed: statusMap.values.where((e) => e.isCompleted).length,
          );

          if (status.completed == status.total && status.total > 0) {
            statusMap.removeWhere((key, value) => value.isCompleted);
            status = DownloaderStatus(
              unknown: statusMap.values.where((e) => e.isUnknown).length,
              running: statusMap.values.where((e) => e.isRunning).length,
              waiting: statusMap.values.where((e) => e.isWaiting).length,
              completed: statusMap.values.where((e) => e.isCompleted).length,
            );
          }
          downloaderStatusStreamController.add(status);
          final handler = downloads[update.task.taskId];

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

  late final FileDownloader fileDownloader;
  final downloads = <String, Future<void> Function({String? errorLog})?>{};
  final statusMap = <String, TaskStatus>{};
  final downloaderStatusStreamController = StreamController<DownloaderStatus>();

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
    downloaderStatusStreamController.close();
  }
}

final downloaderProvider = Provider<Downloader>((ref) {
  final downloader = Downloader();
  ref.onDispose(downloader.dispose);
  return downloader;
});

final downloaderStatusProvider = StreamProvider<DownloaderStatus>(
  (ref) async* {
    yield* ref
        .watch(downloaderProvider)
        .downloaderStatusStreamController
        .stream;
  },
);
