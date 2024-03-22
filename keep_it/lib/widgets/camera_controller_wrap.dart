import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/services.dart';

class CameraControllerWrapper extends CameraController {
  CameraControllerWrapper(
    super.description,
    super.resolutionPreset, {
    super.imageFormatGroup,
  });

  bool get isInitialized => super.value.isInitialized;
  bool get isPreviewPaused => super.value.isPreviewPaused;
  bool get isRecordingVideo => super.value.isRecordingVideo;
  bool get isRecordingPaused => super.value.isRecordingPaused;
  String? get errorDescription => super.value.errorDescription;
  bool get isTakingPicture => super.value.isTakingPicture;
  bool get isCaptureOrientationLocked => super.value.isCaptureOrientationLocked;
  bool get hasError => super.value.hasError;
  FlashMode get flashMode => super.value.flashMode;
  ExposureMode get exposureMode => super.value.exposureMode;
  FocusMode get focusMode => super.value.focusMode;
  @override
  CameraDescription get description => super.value.description;

  DeviceOrientation? get lockedCaptureOrientation {
    _infoLogger('get lockedCaptureOrientation');
    return super.value.lockedCaptureOrientation;
  }

  @override
  Future<void> setExposurePoint(Offset? point) async {
    _infoLogger('setExposurePoint: $point');
    return super.setExposurePoint(point);
  }

  @override
  Future<double> setExposureOffset(double offset) async {
    _infoLogger('setExposureOffset');
    return super.setExposureOffset(offset);
  }

  @override
  Future<void> setFocusPoint(Offset? point) async {
    _infoLogger('setFocusPoint');
    return super.setFocusPoint(point);
  }

  @override
  Future<void> setDescription(CameraDescription description) async {
    _infoLogger('setDescription');
    return super.setDescription(description);
  }

  @override
  Future<void> initialize() async {
    _infoLogger('initialize');
    return super.initialize();
  }

  @override
  void addListener(void Function() listener) {
    _infoLogger('addListener');
    super.addListener(listener);
  }

  @override
  void removeListener(void Function() listener) {
    _infoLogger('removeListener');
    super.removeListener(listener);
  }

  @override
  Future<double> getMinExposureOffset() async {
    _infoLogger('getMinExposureOffset');
    return super.getMinExposureOffset();
  }

  @override
  Future<double> getMaxExposureOffset() async {
    _infoLogger('getMaxExposureOffset');
    return super.getMaxExposureOffset();
  }

  @override
  Future<double> getMaxZoomLevel() async {
    _infoLogger('getMaxZoomLevel');
    return super.getMaxZoomLevel();
  }

  @override
  Future<double> getMinZoomLevel() async {
    _infoLogger('getMinZoomLevel');
    return super.getMinZoomLevel();
  }

  @override
  Future<void> setFlashMode(FlashMode mode) async {
    _infoLogger('setFlashMode: $mode');
    return super.setFlashMode(mode);
  }

  @override
  Future<void> setExposureMode(ExposureMode mode) {
    _infoLogger('setExposureMode: $mode');
    return super.setExposureMode(mode);
  }

  @override
  Future<void> setFocusMode(FocusMode mode) async {
    _infoLogger('setFocusMode: $mode');
    return super.setFocusMode(mode);
  }

  @override
  Future<void> unlockCaptureOrientation() async {
    _infoLogger('unlockCaptureOrientation');
    return super.unlockCaptureOrientation();
  }

  @override
  Future<void> lockCaptureOrientation([DeviceOrientation? orientation]) async {
    _infoLogger('lockCaptureOrientation');
    return super.lockCaptureOrientation(orientation);
  }

  @override
  Future<void> resumePreview() async {
    _infoLogger('resumePreview');
    return super.resumePreview();
  }

  @override
  Future<void> pausePreview() async {
    _infoLogger('pausePreview');
    return super.pausePreview();
  }

  @override
  Future<void> startVideoRecording({
    onLatestImageAvailable? onAvailable,
  }) async {
    _infoLogger('startVideoRecording');
    final res = await super.startVideoRecording(onAvailable: onAvailable);
    _infoLogger('startVideoRecording - Done');
    return res;
  }

  @override
  Future<XFile> stopVideoRecording() async {
    _infoLogger('stopVideoRecording');
    return super.stopVideoRecording();
  }

  @override
  Future<void> pauseVideoRecording() async {
    _infoLogger('pauseVideoRecording');
    return super.pauseVideoRecording();
  }

  @override
  Future<void> resumeVideoRecording() async {
    _infoLogger('resumeVideoRecording');
    return super.resumeVideoRecording();
  }

  @override
  Future<XFile> takePicture() async {
    _infoLogger('takePicture');
    return super.takePicture();
  }
}

const _filePrefix = 'Camera Controller: ';
bool _disableInfoLogger = false;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
