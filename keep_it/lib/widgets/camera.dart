// ignore_for_file: public_member_api_docs, sort_constructors_first

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'Camera/camera_preview.dart';

/// Camera example home widget.
class CameraView extends StatefulWidget {
  /// Default Constructor
  const CameraView({
    required this.cameras,
    super.key,
  });
  final List<CameraDescription> cameras;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        CameraPreviewWithZoom(),
        Spacer(),
      ],
    );
  }
}
