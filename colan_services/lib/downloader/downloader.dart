import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'download_request.dart';
import 'download_status.dart';
import 'download_task.dart';

class DownloadManager {
  factory DownloadManager({
    int? maxConcurrentTasks,
    Dio? dio,
  }) {
    if (maxConcurrentTasks != null) {
      _dm.maxConcurrentTasks = maxConcurrentTasks;
    }

    _dm.dio = dio ?? Dio();

    return _dm;
  }

  DownloadManager._internal();
  final Map<String, DownloadTask> _cache = <String, DownloadTask>{};
  final Queue<DownloadTask> _queue = Queue();
  Dio dio = Dio();
  static const partialExtension = '.partial';
  static const tempExtension = '.temp';

  // var tasks = StreamController<DownloadTask>();

  int maxConcurrentTasks = 2;
  int runningTasks = 0;

  static final DownloadManager _dm = DownloadManager._internal();

  String? requestDownload(
    DownloadRequest downloadRequest,
  ) {
    /// If the uuid already exists,
    /// we should consider this as a duplicate request.
    /// However, we can't replace the callbacks, hence we should
    /// return error (at least for now)
    if (!_cache.containsKey(downloadRequest.uuid)) return null;

    // Create a task, add to queue, update Cache
    final task = DownloadTask(downloadRequest);
    _queue.add(task);
    _cache[downloadRequest.uuid] = task;

    // Trigger the thread if needed
    downloadThread();

    // return task UUID
    return task.request.uuid;
  }

  Future<bool> pauseDownload(String uuid) async {
    if (!_cache.containsKey(uuid)) return false;

    final task = _cache[uuid]!;
    setStatus(task, DownloadStatus.paused);
    task.cancelToken.cancel();
    _queue.remove(task);
    return true;
  }

  Future<bool> cancelDownload(String uuid) async {
    if (!_cache.containsKey(uuid)) return false;

    final task = _cache[uuid]!;
    setStatus(task, DownloadStatus.canceled);
    _queue.remove(task);
    task.cancelToken.cancel();
    return true;
  }

  Future<bool> resumeDownload(String uuid) async {
    if (!_cache.containsKey(uuid)) return false;

    final task = _cache[uuid]!;
    if (!task.isPaused) return false;

    setStatus(task, DownloadStatus.downloading);
    task.cancelToken = CancelToken();
    _queue.add(task);

    await downloadThread();
    return true;
  }

  Future<void> removeDownload(String url) async {
    await cancelDownload(url);
    _cache.remove(url);
  }

  void Function(int, int) createCallback(
    DownloadTask task,
    int partialFileLength,
  ) =>
      (int received, int total) {
        task.progress.value =
            (received + partialFileLength) / (total + partialFileLength);

        if (total == -1) {}
      };

  Future<bool> download(DownloadTask task) async {
    late String partialFilePath;
    late File partialFile;
    try {
      if (task.status.value == DownloadStatus.canceled) {
        return false;
      }
      setStatus(task, DownloadStatus.downloading);

      final file = File(task.request.url);
      final url = task.request.url;
      partialFilePath = task.request.targetFilename + partialExtension;
      partialFile = File(partialFilePath);

      final fileExist = file.existsSync();
      final partialFileExist = partialFile.existsSync();

      if (fileExist) {
        setStatus(task, DownloadStatus.completed);
      } else if (partialFileExist) {
        if (kDebugMode) {
          print('Partial File Exists');
        }

        final partialFileLength = await partialFile.length();

        final response = await dio.download(
          url,
          partialFilePath + tempExtension,
          onReceiveProgress: createCallback(task, partialFileLength),
          options: Options(
            headers: {HttpHeaders.rangeHeader: 'bytes=$partialFileLength-'},
          ),
          cancelToken: task.cancelToken,
        );

        if (response.statusCode == HttpStatus.partialContent) {
          final ioSink = partialFile.openWrite(mode: FileMode.writeOnlyAppend);
          final f0 = File(partialFilePath + tempExtension);
          await ioSink.addStream(f0.openRead());
          await f0.delete();
          await ioSink.close();
          await partialFile.rename(task.request.targetFilename);

          setStatus(task, DownloadStatus.completed);
        }
      } else {
        final response = await dio.download(
          url,
          partialFilePath,
          onReceiveProgress: createCallback(task, 0),
          cancelToken: task.cancelToken,
          deleteOnError: false,
        );

        if (response.statusCode == HttpStatus.ok) {
          await partialFile.rename(task.request.targetFilename);
          setStatus(task, DownloadStatus.completed);
          await task.request.onDone?.call();
        } else {
          await task.request.onError?.call(response.data as String);
        }
      }
    } catch (e) {
      if (task.status.value != DownloadStatus.canceled &&
          task.status.value != DownloadStatus.paused) {
        setStatus(task, DownloadStatus.failed);
        await task.request.onError?.call(e.toString());
      } else if (task.status.value == DownloadStatus.paused) {
        final ioSink = partialFile.openWrite(mode: FileMode.writeOnlyAppend);
        final f = File(partialFilePath + tempExtension);
        if (f.existsSync()) {
          await ioSink.addStream(f.openRead());
        }
        await ioSink.close();
      }
    }

    runningTasks--;
    return true;
  }

  void setStatus(DownloadTask task, DownloadStatus status) =>
      task.status.value = status;

  List<DownloadTask> getAllDownloads() => _cache.values.toList();

  Future<void> downloadThread() async {
    if (runningTasks == maxConcurrentTasks || _queue.isEmpty) {
      return;
    }

    while (_queue.isNotEmpty && runningTasks < maxConcurrentTasks) {
      runningTasks++;
      final currentTask = _queue.removeFirst();

      unawaited(download(currentTask));

      await Future<void>.delayed(const Duration(milliseconds: 1));
    }
  }
}
