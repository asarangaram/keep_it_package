
import 'package:cl_camera/cl_camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'get_cameras.dart';

class CameraServiceCore extends StatelessWidget {
  const CameraServiceCore({
    required this.onReceiveCapturedMedia,
    required this.onCapture,
    required this.previewWidget,
    super.key,
    this.onDone,
  });
  final VoidCallback? onDone;
  final Future<void> Function() onReceiveCapturedMedia;
  final Future<void> Function(
    String path, {
    required bool isVideo,
  }) onCapture;
  final Widget previewWidget;
  @override
  Widget build(BuildContext context) {
    return GetCameras(
      builder: ({
        required cameras,
      }) {
        return CLCamera(
          onCancel: onDone,
          cameras: cameras,
          textStyle: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(fontSize: CLScaleType.small.fontSize),
          onCapture: onCapture,
          previewWidget: previewWidget,
        );
      },
    );
  }
}
