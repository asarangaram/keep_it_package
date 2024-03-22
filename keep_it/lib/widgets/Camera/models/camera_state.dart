// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

@immutable
class CameraState {
  const CameraState({
    required this.controller,
    this.minAvailableExposureOffset = 0,
    this.maxAvailableExposureOffset = 0,
    this.currentExposureOffset = 0,
    this.minAvailableZoom = 0,
    this.maxAvailableZoom = 0,
    this.currentScale = 1.0,
    this.isVideo = false,
    this.isTakingPicture = false,
    this.isRecordingVideo = false,
    this.isRecordingPaused = false,
  });

  static Future<void> createAsync(
    CameraDescription cameraDescription, {
    required void Function(CameraState cameraState) onCameraStateReady,
    required void Function(String e) onCameraError,
  }) async {
    final cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.max,
      imageFormatGroup: ImageFormatGroup.jpeg,
    );

    // If the controller is updated then update the UI.
    cameraController.addListener(() {
      if (cameraController.value.hasError) {
        onCameraError(
          'Camera error ${cameraController.value.errorDescription}',
        );
      }
    });

    try {
      var minAvailableExposureOffset = 0.0;
      var maxAvailableExposureOffset = 0.0;

      var minAvailableZoom = 1.0;
      var maxAvailableZoom = 1.0;
      await cameraController.initialize();
      await Future.wait(<Future<Object?>>[
        cameraController.getMinExposureOffset().then(
              (double value) => minAvailableExposureOffset = value,
            ),
        cameraController.getMaxExposureOffset().then(
              (double value) => maxAvailableExposureOffset = value,
            ),
        cameraController
            .getMaxZoomLevel()
            .then((double value) => maxAvailableZoom = value),
        cameraController
            .getMinZoomLevel()
            .then((double value) => minAvailableZoom = value),
      ]);
      onCameraStateReady(
        CameraState(
          controller: cameraController,
          minAvailableExposureOffset: minAvailableExposureOffset,
          maxAvailableExposureOffset: maxAvailableExposureOffset,
          minAvailableZoom: minAvailableZoom,
          maxAvailableZoom: maxAvailableZoom,
        ),
      );
    } on CameraException catch (e) {
      reportError(e, onCameraError: onCameraError);
    }
  }

  final CameraController controller;
  final double minAvailableExposureOffset;
  final double maxAvailableExposureOffset;
  final double currentExposureOffset;

  final double minAvailableZoom;
  final double maxAvailableZoom;
  final double currentScale;

  final bool isVideo;
  final bool isTakingPicture;
  final bool isRecordingVideo;
  final bool isRecordingPaused;

  void dispose() {
    controller.dispose();
  }

  bool get canPause => isVideo && controller.value.isRecordingVideo;

  CameraState copyWith({
    CameraController? controller,
    double? minAvailableExposureOffset,
    double? maxAvailableExposureOffset,
    double? currentExposureOffset,
    double? minAvailableZoom,
    double? maxAvailableZoom,
    double? currentScale,
    bool? isVideo,
    bool? isTakingPicture,
    bool? isRecordingVideo,
    bool? isRecordingPaused,
  }) {
    return CameraState(
      controller: controller ?? this.controller,
      minAvailableExposureOffset:
          minAvailableExposureOffset ?? this.minAvailableExposureOffset,
      maxAvailableExposureOffset:
          maxAvailableExposureOffset ?? this.maxAvailableExposureOffset,
      currentExposureOffset:
          currentExposureOffset ?? this.currentExposureOffset,
      minAvailableZoom: minAvailableZoom ?? this.minAvailableZoom,
      maxAvailableZoom: maxAvailableZoom ?? this.maxAvailableZoom,
      currentScale: currentScale ?? this.currentScale,
      isVideo: isVideo ?? this.isVideo,
      isTakingPicture: isTakingPicture ?? this.isTakingPicture,
      isRecordingVideo: isRecordingVideo ?? this.isRecordingVideo,
      isRecordingPaused: isRecordingPaused ?? this.isRecordingPaused,
    );
  }

  @override
  bool operator ==(covariant CameraState other) {
    if (identical(this, other)) return true;

    return other.controller == controller &&
        other.minAvailableExposureOffset == minAvailableExposureOffset &&
        other.maxAvailableExposureOffset == maxAvailableExposureOffset &&
        other.currentExposureOffset == currentExposureOffset &&
        other.minAvailableZoom == minAvailableZoom &&
        other.maxAvailableZoom == maxAvailableZoom &&
        other.currentScale == currentScale &&
        other.isVideo == isVideo &&
        other.isTakingPicture == isTakingPicture &&
        other.isRecordingVideo == isRecordingVideo &&
        other.isRecordingPaused == isRecordingPaused;
  }

  @override
  int get hashCode {
    return controller.hashCode ^
        minAvailableExposureOffset.hashCode ^
        maxAvailableExposureOffset.hashCode ^
        currentExposureOffset.hashCode ^
        minAvailableZoom.hashCode ^
        maxAvailableZoom.hashCode ^
        currentScale.hashCode ^
        isVideo.hashCode ^
        isTakingPicture.hashCode ^
        isRecordingVideo.hashCode ^
        isRecordingPaused.hashCode;
  }

  @override
  String toString() {
    return 'CameraState(controller: $controller, minAvailableExposureOffset: $minAvailableExposureOffset, maxAvailableExposureOffset: $maxAvailableExposureOffset, currentExposureOffset: $currentExposureOffset, minAvailableZoom: $minAvailableZoom, maxAvailableZoom: $maxAvailableZoom, currentScale: $currentScale, isVideo: $isVideo, isTakingPicture: $isTakingPicture, isRecordingVideo: $isRecordingVideo, isRecordingPaused: $isRecordingPaused)';
  }

  Future<void> setExposureOffset(
    double offset, {
    required void Function(CameraState? cameraState) updateCameraState,
    required void Function(String) onCameraError,
  }) async {
    final oldValue = currentExposureOffset;
    updateCameraState(copyWith(currentExposureOffset: offset));

    try {
      updateCameraState(
        copyWith(
          currentExposureOffset: await controller.setExposureOffset(offset),
        ),
      );
    } on CameraException catch (e) {
      copyWith(currentExposureOffset: oldValue);
      reportError(e, onCameraError: onCameraError);
      rethrow;
    }
  }

  static void reportError(
    CameraException e, {
    required void Function(String) onCameraError,
  }) {
    final String errorString;
    switch (e.code) {
      case 'CameraAccessDenied':
        errorString = 'You have denied camera access.';
      case 'CameraAccessDeniedWithoutPrompt':
        // iOS only
        errorString = 'Please go to Settings app to enable camera access.';
      case 'CameraAccessRestricted':
        // iOS only
        errorString = 'Camera access is restricted.';
      case 'AudioAccessDenied':
        errorString = 'You have denied audio access.';
      case 'AudioAccessDeniedWithoutPrompt':
        // iOS only
        errorString = 'Please go to Settings app to enable audio access.';
      case 'AudioAccessRestricted':
        // iOS only
        errorString = 'Audio access is restricted.';
      default:
        errorString = e.toString();
        break;
    }
    return onCameraError(errorString);
  }

  Future<CameraState> setZoomLevel(double value) async {
    try {
      final currentScale = value.clamp(minAvailableZoom, maxAvailableZoom);
      await controller.setZoomLevel(currentScale);
      return copyWith(currentScale: currentScale);
    } catch (e) {
      return this;
    }
  }

  Future<CameraState> setFocusPoint(Offset value) async {
    try {
      await controller.setExposurePoint(value);
    } catch (e) {
      /* Some Cameras don't support. Ignore it. */
    }
    try {
      await controller.setFocusPoint(value);
    } catch (e) {
      /* Some Cameras don't support. Ignore it. */
    }

    /// Should we store this offset? do we need to implement anything else?
    return this;
  }
}
