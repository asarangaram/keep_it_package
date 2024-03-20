// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

@immutable
class CameraSelector {
  final List<CameraDescription> cameras;
  final int currentIndex;
  factory CameraSelector({required List<CameraDescription> cameras}) {
    return CameraSelector._(cameras: cameras, currentIndex: 0);
  }
  const CameraSelector._({
    required this.cameras,
    required this.currentIndex,
  });

  CameraSelector copyWith({
    int? currentIndex,
  }) {
    return CameraSelector._(
      cameras: cameras,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }
}
