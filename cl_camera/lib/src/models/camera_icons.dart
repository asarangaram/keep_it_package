import 'package:flutter/material.dart';

@immutable
class CameraIcons {
  const CameraIcons({
    required this.imageCamera,
    required this.videoCamera,
    required this.pauseRecording,
    required this.resumeRecording,
  });
  final IconData imageCamera;
  final IconData videoCamera;
  final IconData pauseRecording;
  final IconData resumeRecording;
}
