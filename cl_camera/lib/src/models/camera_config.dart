// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';

@immutable
class CameraConfig {
  const CameraConfig({
    this.resolutionPreset = ResolutionPreset.medium,
    this.enableAudio = true,
    this.defaultFrontCameraIndex = 0,
    this.defaultBackCameraIndex = 0,
  });

  final ResolutionPreset resolutionPreset;
  final bool enableAudio;
  final int defaultFrontCameraIndex;
  final int defaultBackCameraIndex;

  CameraConfig copyWith({
    ResolutionPreset? resolutionPreset,
    bool? enableAudio,
    int? defaultFrontCameraIndex,
    int? defaultBackCameraIndex,
  }) {
    return CameraConfig(
      resolutionPreset: resolutionPreset ?? this.resolutionPreset,
      enableAudio: enableAudio ?? this.enableAudio,
      defaultFrontCameraIndex:
          defaultFrontCameraIndex ?? this.defaultFrontCameraIndex,
      defaultBackCameraIndex:
          defaultBackCameraIndex ?? this.defaultBackCameraIndex,
    );
  }

  @override
  String toString() {
    return 'CameraConfig(resolutionPreset: $resolutionPreset, '
        'enableAudio: $enableAudio, defaultFrontCameraIndex: '
        '$defaultFrontCameraIndex, '
        'defaultBackCameraIndex: $defaultBackCameraIndex)';
  }

  @override
  bool operator ==(covariant CameraConfig other) {
    if (identical(this, other)) return true;

    return other.resolutionPreset == resolutionPreset &&
        other.enableAudio == enableAudio &&
        other.defaultFrontCameraIndex == defaultFrontCameraIndex &&
        other.defaultBackCameraIndex == defaultBackCameraIndex;
  }

  @override
  int get hashCode {
    return resolutionPreset.hashCode ^
        enableAudio.hashCode ^
        defaultFrontCameraIndex.hashCode ^
        defaultBackCameraIndex.hashCode;
  }
}
/* 
class CameraConfigNotifier extends StateNotifier<CameraConfig> {
  CameraConfigNotifier() : super(const CameraConfig());

  ResolutionPreset get resolutionPreset => state.resolutionPreset;
  bool get enableAudio => state.enableAudio;
  int get defaultFrontCameraIndex => state.defaultBackCameraIndex;
  int get defaultBackCameraIndex => state.defaultBackCameraIndex;

  set resolutionPreset(ResolutionPreset val) {
    state = state.copyWith(resolutionPreset: val);
  }

  set enableAudio(bool val) {
    state = state.copyWith(enableAudio: val);
  }

  set defaultFrontCameraIndex(int val) {
    state = state.copyWith(defaultBackCameraIndex: val);
  }

  set defaultBackCameraIndex(int val) {
    state = state.copyWith(defaultBackCameraIndex: val);
  }
}

final cameraConfigProvider =
    StateNotifierProvider<CameraConfigNotifier, CameraConfig>((ref) {
  return CameraConfigNotifier();
});
 */
