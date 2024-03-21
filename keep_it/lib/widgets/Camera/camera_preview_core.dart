import 'package:flutter/material.dart';
import 'package:keep_it/widgets/Camera/models/camera_state.dart';

class CameraPreviewCore extends StatelessWidget {
  const CameraPreviewCore({required this.cameraState, super.key});
  final CameraState cameraState;

  @override
  Widget build(BuildContext context) => cameraState.controller.buildPreview();
}
