// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

@immutable
class CameraSettings {
  const CameraSettings({
    this.cameraIndex = 1,
    this.resolutionPreset = ResolutionPreset.max,
    this.enableAudio = true,
    this.minAvailableZoom = 1,
    this.maxAvailableZoom = 1,
    this.zoomLevel0 = 1.0,
  });
  final int cameraIndex;
  final ResolutionPreset resolutionPreset;
  final bool enableAudio;
  final double minAvailableZoom;
  final double maxAvailableZoom;
  final double zoomLevel0;

  CameraSettings copyWith({
    int? cameraIndex,
    ResolutionPreset? resolutionPreset,
    bool? enableAudio,
    double? minAvailableZoom,
    double? maxAvailableZoom,
    double? zoomLevel0,
  }) {
    return CameraSettings(
      cameraIndex: cameraIndex ?? this.cameraIndex,
      resolutionPreset: resolutionPreset ?? this.resolutionPreset,
      enableAudio: enableAudio ?? this.enableAudio,
      minAvailableZoom: minAvailableZoom ?? this.minAvailableZoom,
      maxAvailableZoom: maxAvailableZoom ?? this.maxAvailableZoom,
      zoomLevel0: zoomLevel0 ?? this.zoomLevel0,
    );
  }

  @override
  bool operator ==(covariant CameraSettings other) {
    if (identical(this, other)) return true;

    return other.cameraIndex == cameraIndex &&
        other.resolutionPreset == resolutionPreset &&
        other.enableAudio == enableAudio &&
        other.minAvailableZoom == minAvailableZoom &&
        other.maxAvailableZoom == maxAvailableZoom &&
        other.zoomLevel0 == zoomLevel0;
  }

  @override
  int get hashCode {
    return cameraIndex.hashCode ^
        resolutionPreset.hashCode ^
        enableAudio.hashCode ^
        minAvailableZoom.hashCode ^
        maxAvailableZoom.hashCode ^
        zoomLevel0.hashCode;
  }

  @override
  String toString() {
    return 'CameraSettings(cameraIndex: $cameraIndex, '
        'resolutionPreset: $resolutionPreset, enableAudio: $enableAudio, '
        'minAvailableZoom: $minAvailableZoom, '
        'maxAvailableZoom: $maxAvailableZoom, zoomLevel0: $zoomLevel0)';
  }

  CameraSettings zoomLevel(double value) => copyWith(
        zoomLevel0: value.clamp(minAvailableZoom, maxAvailableZoom),
      );
}
