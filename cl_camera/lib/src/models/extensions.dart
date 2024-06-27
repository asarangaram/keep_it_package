import 'package:camera/camera.dart';

extension ExtCameraController on CameraController {
  Future<void> onStartVideoRecording({
    required void Function() onSuccess,
    required void Function(String message, {required dynamic error})? onError,
  }) async {
    if (!value.isRecordingVideo) {
      try {
        await startVideoRecording();
        onSuccess();
      } on CameraException catch (e) {
        onError?.call('Error starting to record video', error: e);
      }
    }
  }

  Future<void> onStopVideoRecording({
    required void Function(String videoFilePath) onSuccess,
    required void Function(String message, {required dynamic error})? onError,
  }) async {
    if (value.isRecordingVideo) {
      try {
        final file = await stopVideoRecording();
        onSuccess(file.path);
      } on CameraException catch (e) {
        onError?.call('Error stopping video recording', error: e);
      }
    }
  }

  Future<void> onPauseVideoRecording({
    required void Function() onSuccess,
    required void Function(String message, {required dynamic error})? onError,
  }) async {
    if (value.isRecordingVideo) {
      try {
        await pauseVideoRecording();
        onSuccess();
      } on CameraException catch (e) {
        onError?.call('Error pausing video recording', error: e);
      }
    }
  }

  Future<void> onResumeVideoRecording({
    required void Function() onSuccess,
    required void Function(String message, {required dynamic error})? onError,
  }) async {
    if (value.isRecordingVideo) {
      try {
        await resumeVideoRecording();
        onSuccess();
      } on CameraException catch (e) {
        onError?.call('Error resuming video recording', error: e);
      }
      return;
    }
  }

  Future<void> onTakePicture({
    required void Function(String imageFilePath) onSuccess,
    required void Function(String message, {required dynamic error})? onError,
  }) async {
    if (value.isTakingPicture) {
      // A capture is already pending, do nothing.
      return;
    }

    try {
      final file = await takePicture();
      onSuccess(file.path);
    } on CameraException catch (e) {
      onError?.call('Error occured while taking picture', error: e);
    }
  }
}
