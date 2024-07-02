import 'package:cl_camera/cl_camera.dart';
import 'package:flutter/material.dart';

import '../theme/default_theme.dart';
import 'get_cameras.dart';

class CameraServiceCore extends StatelessWidget {
  const CameraServiceCore({
    required this.onReceiveCapturedMedia,
    required this.onCapture,
    required this.previewWidget,
    super.key,
    this.onDone,
    this.onError,
  });
  final VoidCallback? onDone;
  final Future<void> Function() onReceiveCapturedMedia;
  final Future<void> Function(
    String path, {
    required bool isVideo,
  }) onCapture;
  final Widget previewWidget;
  final void Function(String, {required dynamic error})? onError;
  @override
  Widget build(BuildContext context) {
    return GetCameras(
      builder: ({
        required cameras,
      }) {
        return CLCamera(
          onCancel: onDone,
          cameras: cameras,
          onCapture: onCapture,
          previewWidget: previewWidget,
          themeData: DefaultCLCameraThemeData(),
          onError: onError,
        );
      },
    );
  }
}
