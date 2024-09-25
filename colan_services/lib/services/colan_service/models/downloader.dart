// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:background_downloader/background_downloader.dart';

import 'downloader_status.dart';

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
  final void Function(DownloaderStatus status) onStatusUpdate;
  Downloader(this.onStatusUpdate) {
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
          onStatusUpdate(status);

          downloaderStatusStreamController.add(status);
          final handler = downloads[update.task.taskId];

          switch (update.status) {
            case TaskStatus.complete:
              handler?.call(update.task, status: update);
            case TaskStatus.failed:
              handler?.call(
                update.task,
                errorLog: update.responseBody ?? 'Unknown Error',
                status: update,
              );
            case TaskStatus.canceled:
              handler?.call(
                update.task,
                errorLog: 'Download cancelled, try again',
                status: update,
              );
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
  final downloads = <String,
      Future<void> Function(
    Task task, {
    required TaskStatusUpdate status,
    String? errorLog,
  })?>{};
  final statusMap = <String, TaskStatus>{};
  final downloaderStatusStreamController = StreamController<DownloaderStatus>();

  Future<DownloadTask> enqueue({
    required String url,
    required BaseDirectory baseDirectory,
    required String directory,
    required String filename,
    Future<void> Function(
      Task task, {
      required TaskStatusUpdate status,
      String? errorLog,
    })? onDone,
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

    await fileDownloader.enqueue(task);
    return task;
  }

  Future<UploadTask> enqueueUpload({
    required String url,
    required BaseDirectory baseDirectory,
    required String directory,
    required String filename,
    required Map<String, String> fields,
    Future<void> Function(
      Task task, {
      required TaskStatusUpdate status,
      String? errorLog,
    })? onDone,
    String group = 'upload',
  }) async {
    final task = UploadTask(
      url: url,
      filename: filename,
      fileField: 'media',
      fields: fields,
      directory: directory,
      baseDirectory: baseDirectory,
      group: group,
    );

    downloads[task.taskId] = onDone;

    await fileDownloader.enqueue(task);
    return task;
  }

  Future<bool> cancel(String taskId) async {
    return fileDownloader.cancelTaskWithId(taskId);
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
