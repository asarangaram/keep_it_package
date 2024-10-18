// ignore_for_file: avoid_print

import 'dart:async';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test BackgroundDownloader download task',
      (WidgetTester tester) async {
    // Step 1: Initialize the downloader
    final downloader = FileDownloader();

    // Step 2: Define the task (Download a small test file)
    final task = DownloadTask(
      url:
          'https://file-examples.com/wp-content/storage/2017/04/file_example_MP4_480_1_5MG.mp4', // URL to download a test file
      filename: 'file_example_MP4_480_1_5MG.mp4',
    );
    final completer = Completer<bool>();
    final result = await downloader.download(
      task,
      onProgress: (progress) {
        print('Progress: ${progress * 100}%');
      },
      onStatus: (status) {
        print('Status: $status');
        if (status.isFinalState) {
          completer.complete(status == TaskStatus.complete);
        }
      },
    );

// Act on the result
    switch (result.status) {
      case TaskStatus.complete:
        print('Success!');

      case TaskStatus.canceled:
        print('Download was canceled');

      case TaskStatus.paused:
        print('Download was paused');

      case TaskStatus.enqueued:
      case TaskStatus.running:
      case TaskStatus.notFound:
      case TaskStatus.failed:
      case TaskStatus.waitingToRetry:
        print('download not completed');
    }
    final isSuccess = await completer.future;
    print('download success? $isSuccess');
    print('test completed');
    expect(isSuccess, true);
  });
}
