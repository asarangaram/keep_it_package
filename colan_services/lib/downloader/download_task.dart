import 'dart:async';
import 'dart:ffi';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'download_request.dart';
import 'download_status.dart';

class DownloadTask {
  DownloadTask(
    this.request,
  );
  final DownloadRequest request;
  ValueNotifier<DownloadStatus> status = ValueNotifier(DownloadStatus.queued);
  ValueNotifier<double> progress = ValueNotifier(0);
  CancelToken cancelToken = CancelToken();

  Future<DownloadStatus> whenDownloadComplete({
    Duration timeout = const Duration(hours: 2),
  }) async {
    final completer = Completer<DownloadStatus>();

    if (status.value.isCompleted) {
      completer.complete(status.value);
    }

    void listener() {
      if (status.value.isCompleted) {
        completer.complete(status.value);
        status.removeListener(listener);
      }
    }

    status.addListener(listener);

    return completer.future.timeout(timeout);
  }

  bool get isPaused => status.value == DownloadStatus.paused;
}
