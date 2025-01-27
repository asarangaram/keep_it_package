import 'dart:convert';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

extension ExtResolutionPreset on ResolutionPreset {
  String toMap() {
    return name;
  }

  static ResolutionPreset fromString(String value) {
    return ResolutionPreset.values.asNameMap()[value]!;
  }
}

@immutable
class CameraConfig {
  const CameraConfig({
    this.resolutionPreset = ResolutionPreset.medium,
    this.enableAudio = true,
    this.defaultFrontCameraIndex = 0,
    this.defaultBackCameraIndex = 0,
  });

  factory CameraConfig.fromMap(Map<String, dynamic> map) {
    return CameraConfig(
      resolutionPreset: ExtResolutionPreset.fromString(
        map['resolutionPreset'] as String,
      ),
      enableAudio: map['enableAudio'] as bool,
      defaultFrontCameraIndex: map['defaultFrontCameraIndex'] as int,
      defaultBackCameraIndex: map['defaultBackCameraIndex'] as int,
    );
  }

  factory CameraConfig.fromJson(String source) =>
      CameraConfig.fromMap(json.decode(source) as Map<String, dynamic>);

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

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'resolutionPreset': resolutionPreset.toMap(),
      'enableAudio': enableAudio,
      'defaultFrontCameraIndex': defaultFrontCameraIndex,
      'defaultBackCameraIndex': defaultBackCameraIndex,
    };
  }

  String toJson() => json.encode(toMap());

  static Future<CameraConfig> loadConfig() async {
    final prefs = await SharedPreferences.getInstance();
    final prefJSON = prefs.getString('cameraConfig');
    if (prefJSON == null) {
      const config = CameraConfig();
      await prefs.setString('cameraConfig', config.toJson());
      return config;
    }
    return CameraConfig.fromJson(prefJSON);
  }

  // Never allow Audio to be muted when starting the camera
  Future<void> saveConfig() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('cameraConfig', copyWith(enableAudio: true).toJson());
  }
}
