import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'camera_preview.dart';
import 'camera_preview_core.dart';
import 'models/camera_state.dart';

class CameraFullScreen extends StatefulWidget {
  const CameraFullScreen({required this.cameraState, super.key});
  final CameraState cameraState;

  @override
  State<CameraFullScreen> createState() => _CameraFullScreenState();
}

class _CameraFullScreenState extends State<CameraFullScreen> {
  @override
  void initState() {
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.leanBack);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: SystemUiOverlay.values,
    );
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cameraState = widget.cameraState;
    return Stack(
      fit: StackFit.expand,
      children: [
        CameraPreviewCore(
          cameraState: cameraState,
        ),
        Positioned.fill(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(
              color: Colors.black.withOpacity(0.5), // Adjust opacity as needed
            ),
          ),
        ),
        CameraPreviewWidget(
          cameraState: cameraState,
        ),
      ],
    );
  }
}
