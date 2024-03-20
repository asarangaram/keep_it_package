// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:camera/camera.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'camera_settings.dart';

@immutable
class CameraState {
  CameraState({
    required this.cameras,
    required this.cameraSettings,
    CameraDescription? currentCamera,
  }) : currentCamera = currentCamera ?? cameras[0];
  final List<CameraDescription> cameras;
  final CameraDescription currentCamera;
  final CameraSettings cameraSettings;

  CameraState copyWith({
    List<CameraDescription>? cameras,
    CameraDescription? currentCamera,
    CameraSettings? cameraSettings,
  }) {
    return CameraState(
      cameras: cameras ?? this.cameras,
      currentCamera: currentCamera ?? this.currentCamera,
      cameraSettings: cameraSettings ?? this.cameraSettings,
    );
  }

  @override
  bool operator ==(covariant CameraState other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.cameras, cameras) &&
        other.currentCamera == currentCamera &&
        other.cameraSettings == cameraSettings;
  }

  @override
  int get hashCode =>
      cameras.hashCode ^ currentCamera.hashCode ^ cameraSettings.hashCode;

  @override
  String toString() =>
      'CameraState(cameras: $cameras, currentCamera: $currentCamera, '
      'cameraSettings: $cameraSettings)';

  CameraState zoomLevel(double value) =>
      copyWith(cameraSettings: cameraSettings.zoomLevel(value));

  CameraState nextResolution() {
    final settings = cameraSettings.nextResolution();
    return copyWith(cameraSettings: settings);
  }
}
