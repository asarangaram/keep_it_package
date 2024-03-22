import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

class CameraControllerWrapper {
  CameraControllerWrapper(
    CameraDescription description,
    ResolutionPreset resolutionPreset, {
    ImageFormatGroup? imageFormatGroup,
  }) : controller = CameraController(
          description,
          resolutionPreset,
          imageFormatGroup: imageFormatGroup,
        );

  final CameraController controller;

  bool get isInitialized => controller.value.isInitialized;
  bool get isPreviewPaused => controller.value.isPreviewPaused;
  bool get isRecordingVideo => controller.value.isRecordingVideo;
  bool get isRecordingPaused => controller.value.isRecordingPaused;
  String? get errorDescription => controller.value.errorDescription;
  bool get isTakingPicture => controller.value.isTakingPicture;
  bool get isCaptureOrientationLocked =>
      controller.value.isCaptureOrientationLocked;
  bool get hasError => controller.value.hasError;
  FlashMode get flashMode => controller.value.flashMode;
  ExposureMode get exposureMode => controller.value.exposureMode;
  FocusMode get focusMode => controller.value.focusMode;
  Future<void> dispose() => controller.dispose();

  CameraDescription get description => controller.value.description;

  Future<void> setZoomLevel(double zoom) => controller.setZoomLevel(zoom);
  Future<void> setExposurePoint(Offset? point) =>
      controller.setExposurePoint(point);
  Future<double> setExposureOffset(double offset) =>
      controller.setExposureOffset(offset);
  Future<void> setFocusPoint(Offset? point) => controller.setFocusPoint(point);
  Future<void> setDescription(CameraDescription description) =>
      controller.setDescription(description);

  Future<void> initialize() => controller.initialize();

  Future<double> getMinExposureOffset() => controller.getMinExposureOffset();

  DeviceOrientation? get lockedCaptureOrientation =>
      controller.value.lockedCaptureOrientation;
  void addListener(void Function() listener) =>
      controller.addListener(listener);
  void removeListener(void Function() listener) =>
      controller.removeListener(listener);

  Future<double> getMaxExposureOffset() => controller.getMaxExposureOffset();
  Future<double> getMaxZoomLevel() => controller.getMaxZoomLevel();
  Future<double> getMinZoomLevel() => controller.getMinZoomLevel();
  Future<void> unlockCaptureOrientation() =>
      controller.unlockCaptureOrientation();
  Future<void> lockCaptureOrientation() => controller.lockCaptureOrientation();

  Future<void> resumePreview() => controller.resumePreview();
  Future<void> pausePreview() => controller.pausePreview();
  Future<void> startVideoRecording() => controller.startVideoRecording();
  Future<XFile> stopVideoRecording() => controller.stopVideoRecording();
  Future<void> pauseVideoRecording() => controller.pauseVideoRecording();
  Future<void> resumeVideoRecording() => controller.resumeVideoRecording();
  Future<XFile> takePicture() => controller.takePicture();
  Future<void> setFlashMode(FlashMode mode) => controller.setFlashMode(mode);
  Future<void> setExposureMode(ExposureMode mode) =>
      controller.setExposureMode(mode);
  Future<void> setFocusMode(FocusMode mode) => controller.setFocusMode(mode);
}
