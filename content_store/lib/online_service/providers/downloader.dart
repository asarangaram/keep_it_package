import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';

import '../models/downloader_status.dart';

@immutable
class TransferCompleter {
  const TransferCompleter({required this.task, this.onDone});
  final Task task;
  final Future<void> Function(TaskStatusUpdate update)? onDone;
}

extension StatisticsExtOnTaskStatus on TaskStatus {
  bool get isWaiting => [
        TaskStatus.enqueued,
        TaskStatus.waitingToRetry,
        TaskStatus.paused,
      ].contains(this);
  bool get isRunning => this == TaskStatus.running;
  bool get isCompleted => isFinalState;
  bool get isUnknown => this == TaskStatus.notFound;
}

class DownloaderNotifier extends StateNotifier<DownloaderStatus> {
  DownloaderNotifier() : super(const DownloaderStatus()) {
    fileDownloader = FileDownloader();

    FileDownloader().updates.listen((update) {
      switch (update) {
        case TaskStatusUpdate():
          final statusMap = <String, TaskStatus>{};
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

          if (update.status.isCompleted) {
            final handler = transfer[update.task.taskId];
            handler?.onDone?.call(update);
          }
          state = status;

        case TaskProgressUpdate():
          break;
      }
    });
  }

  late final FileDownloader fileDownloader;
  final transfer = <String, TransferCompleter>{};

  TransferCompleter enqueue({
    required Task task,
    Future<void> Function(TaskStatusUpdate)? onDone,
  }) {
    transfer[task.taskId] = TransferCompleter(task: task, onDone: onDone);

    fileDownloader.enqueue(task);
    return transfer[task.taskId]!;
  }

  Future<bool> cancel(String taskId) async {
    return fileDownloader.cancelTaskWithId(taskId);
  }

  Future<void> removeCompleted() async {
    final records = await fileDownloader.database.allRecords();

    transfer.removeWhere((key, value) {
      return records
              .where((e) => e.taskId == key)
              .firstOrNull
              ?.status
              .isCompleted ??
          false;
    });
  }

  Future<void> cancelAll() async {
    await fileDownloader
        .cancelTasksWithIds(transfer.values.map((e) => e.task.taskId).toList());
  }

  @override
  void dispose() {
    cancelAll();
    super.dispose();
  }
}

final downloaderProvider =
    StateNotifierProvider<DownloaderNotifier, DownloaderStatus>((ref) {
  return DownloaderNotifier();
});
