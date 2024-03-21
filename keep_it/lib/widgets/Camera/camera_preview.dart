import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'camera_gesture.dart';
import 'camera_preview_core.dart';
import 'models/camera_state.dart';

class CameraPreviewWidget extends StatefulWidget {
  const CameraPreviewWidget({
    required this.cameraState,
    this.children = const [],
    super.key,
  });
  final CameraState cameraState;
  final List<Widget> children;

  @override
  State<StatefulWidget> createState() => CameraPreviewWidgetState();
}

class CameraPreviewWidgetState extends State<CameraPreviewWidget> {
  // Counting pointers (number of user fingers on screen)

  @override
  Widget build(BuildContext context) {
    final controller = widget.cameraState.controller;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.transparent,
      ),
      child: Center(
        child: ValueListenableBuilder<CameraValue>(
          valueListenable: controller,
          builder: (BuildContext context, Object? value, Widget? child) {
            return AspectRatio(
              aspectRatio: 1 / controller.value.aspectRatio,
              child: Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CameraPreviewCore(
                    cameraState: widget.cameraState,
                  ),
                  ...widget.children,
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class AspectRatioConditional extends StatelessWidget {
  const AspectRatioConditional({
    required this.child,
    super.key,
    this.aspectRatio,
  });
  final double? aspectRatio;
  final Widget child;

  @override
  Widget build(
    BuildContext context,
  ) {
    if (aspectRatio == null) return child;
    return AspectRatio(
      aspectRatio: aspectRatio!,
      child: child,
    );
  }
}
