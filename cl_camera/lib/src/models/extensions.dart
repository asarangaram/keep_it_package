// TODO(anandas): : Remove prints
// ignore_for_file: avoid_print

import 'dart:ui';

import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';

extension EXTNextOnList<T> on List<T> {
  T next(T item) => this[(indexOf(item) + 1) % length];
}

mixin CameraMixin {
  static String getCameraName(
    List<CameraDescription> cameras,
    CameraDescription description,
  ) {
    final directionCameras = cameras
        .where((element) => element.lensDirection == description.lensDirection)
        .toList();

    if (directionCameras.length == 1) {
      return description.lensDirection.name.capitalizeFirstLetter();
    } else {
      return '${description.lensDirection.name.capitalizeFirstLetter()}'
          '-${directionCameras.indexOf(description)}';
    }
  }

  static String getResolutionString(Size? previewSize) {
    if (previewSize == null) return 'Unknown';
    return '${previewSize.width.toInt()}x${previewSize.height.toInt()}';
  }
}

extension ExtCameraController on CameraController {
  Future<void> onStartVideoRecording({
    required void Function() onSuccess,
  }) async {
    if (!value.isRecordingVideo) {
      try {
        await startVideoRecording();
        onSuccess();
      } on CameraException catch (e) {
        print('Error starting to record video: $e');
      }
    }
  }

  Future<void> onStopVideoRecording({
    required void Function(String videoFilePath) onSuccess,
  }) async {
    if (value.isRecordingVideo) {
      try {
        final file = await stopVideoRecording();
        onSuccess(file.path);
      } on CameraException catch (e) {
        print('Error stopping video recording: $e');
      }
    }
  }

  Future<void> onPauseVideoRecording({
    required void Function() onSuccess,
  }) async {
    if (value.isRecordingVideo) {
      try {
        await pauseVideoRecording();
        onSuccess();
      } on CameraException catch (e) {
        print('Error pausing video recording: $e');
      }
    }
  }

  Future<void> onResumeVideoRecording({
    required void Function() onSuccess,
  }) async {
    if (value.isRecordingVideo) {
      try {
        await resumeVideoRecording();
        onSuccess();
      } on CameraException catch (e) {
        print('Error resuming video recording: $e');
      }
      return;
    }
  }

  Future<void> onTakePicture({
    required void Function(String imageFilePath) onSuccess,
  }) async {
    if (value.isTakingPicture) {
      // A capture is already pending, do nothing.
    }

    try {
      final file = await takePicture();
      onSuccess(file.path);
    } on CameraException catch (e) {
      print('Error occured while taking picture: $e');
    }
  }
}
