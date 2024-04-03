import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'camera_gesture.dart';
import 'flash_control.dart';

class CameraPreviewLayer extends StatelessWidget {
  const CameraPreviewLayer({
    required this.controller,
    required this.currentZoomLevel,
    required this.onChangeZoomLevel,
    super.key,
  });
  final CameraController controller;
  final double currentZoomLevel;
  final void Function(double) onChangeZoomLevel;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1 / controller.value.aspectRatio,
      child: Stack(
        children: [
          CameraPreview(
            controller,
            child: LayoutBuilder(
              builder: (
                BuildContext context,
                BoxConstraints constraints,
              ) {
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: (details) => onViewFinderTap(
                    details,
                    constraints,
                  ),
                );
              },
            ),
          ),
          CameraGesture(
            currentZoomLevel: currentZoomLevel,
            onChangeZoomLevel: onChangeZoomLevel,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: FlashControl(controller: controller),
          ),
        ],
      ),
    );
  }

  void onViewFinderTap(TapDownDetails details, BoxConstraints constraints) {
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    controller
      ..setExposurePoint(offset)
      ..setFocusPoint(offset);
  }
}
