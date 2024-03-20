import 'package:flutter/material.dart';

import 'Camera/camera_preview.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key});

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
