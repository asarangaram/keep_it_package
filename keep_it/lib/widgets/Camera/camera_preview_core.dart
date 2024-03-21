import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CameraPreviewCore extends StatelessWidget {
  const CameraPreviewCore({required this.controller, super.key});
  final CameraController controller;

  @override
  Widget build(BuildContext context) =>
      _wrapInRotatedBox(child: controller.buildPreview());

  Widget _wrapInRotatedBox({required Widget child}) {
    /* if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      return child;
    } */

    return RotatedBox(
      quarterTurns: _getQuarterTurns(),
      child: child,
    );
  }

  int _getQuarterTurns() {
    final turns = <DeviceOrientation, int>{
      DeviceOrientation.portraitUp: 0,
      DeviceOrientation.landscapeRight: 1,
      DeviceOrientation.portraitDown: 2,
      DeviceOrientation.landscapeLeft: 3,
    };
    return turns[_getApplicableOrientation()]!;
  }

  DeviceOrientation _getApplicableOrientation() {
    return controller.value.isRecordingVideo
        ? controller.value.recordingOrientation!
        : (controller.value.previewPauseOrientation ??
            controller.value.lockedCaptureOrientation ??
            controller.value.deviceOrientation);
  }
}
