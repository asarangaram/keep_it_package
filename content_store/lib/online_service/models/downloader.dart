// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';

import 'downloader_status.dart';

@immutable
class TaskCompleterResult {
  const TaskCompleterResult({
    required this.status,
    this.errorLog,
  });

  final TaskStatusUpdate status;
  final String? errorLog;

  @override
  String toString() => 'TaskCompleterResult(status: ${status.responseBody}, '
      'errorLog: $errorLog)';
}

@immutable
class TransferHandle {
  const TransferHandle(this.task, this.completer);
  final Task task;
  final Completer<TaskCompleterResult> completer;
}

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

          final handler = transfer[update.task.taskId];

          switch (update.status) {
            case TaskStatus.complete:
              handler?.completer.complete(
                TaskCompleterResult(status: update),
              );

            case TaskStatus.failed:
              handler?.completer.complete(
                TaskCompleterResult(
                  status: update,
                  errorLog: update.responseBody ?? 'Unknown Error',
                ),
              );

            case TaskStatus.canceled:
              handler?.completer.complete(
                TaskCompleterResult(
                  status: update,
                  errorLog: 'Download cancelled, try again',
                ),
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
  final transfer = <String, TransferHandle>{};
  final statusMap = <String, TaskStatus>{};

  TransferHandle enqueue({
    required String url,
    required BaseDirectory baseDirectory,
    required String directory,
    required String filename,
    String group = 'Unclassified',
  }) {
    final task = DownloadTask(
      url: url,
      filename: filename,
      directory: directory,
      baseDirectory: baseDirectory,
      group: group,
    );

    transfer[task.taskId] =
        TransferHandle(task, Completer<TaskCompleterResult>());
    fileDownloader.enqueue(task);
    return transfer[task.taskId]!;
  }

  TransferHandle enqueueUpload({
    required String url,
    required BaseDirectory baseDirectory,
    required String directory,
    required String filename,
    required Map<String, String> fields,
    String group = 'upload',
  }) {
    final task = UploadTask(
      url: url,
      filename: filename,
      fileField: 'media',
      fields: fields,
      directory: directory,
      baseDirectory: baseDirectory,
      group: group,
    );

    transfer[task.taskId] =
        TransferHandle(task, Completer<TaskCompleterResult>());

    fileDownloader.enqueue(task);
    return transfer[task.taskId]!;
  }

  Future<bool> cancel(String taskId) async {
    return fileDownloader.cancelTaskWithId(taskId);
  }

  Future<void> removeCompleted() async {
    final records = await fileDownloader.database.allRecords();

    transfer.removeWhere((key, value) {
      return records.where((e) => e.taskId == key).firstOrNull?.status ==
          TaskStatus.complete;
    });
  }
}
