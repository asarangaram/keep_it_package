import 'package:flutter/material.dart';
import 'package:keep_it/widgets/Camera/models/camera_state.dart';

class CameraGesture extends StatefulWidget {
  const CameraGesture({required this.cameraState, super.key});
  final CameraState cameraState;

  @override
  State<CameraGesture> createState() => _CameraGestureState();
}

class _CameraGestureState extends State<CameraGesture> {
  // Counting pointers (number of user fingers on screen)
  int pointers = 0;
  double currentScale = 1;
  double baseScale = 1;
  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: (_) => pointers++,
      onPointerUp: (_) => pointers--,
      child: LayoutBuilder(
        builder: (
          BuildContext context,
          BoxConstraints constraints,
        ) {
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onScaleStart: _handleScaleStart,
            onScaleUpdate: _handleScaleUpdate,
            onTapDown: (TapDownDetails details) =>
                onViewFinderTap(details, constraints),
          );
        },
      ),
    );
  }

  void _handleScaleStart(ScaleStartDetails details) {
    baseScale = currentScale;

    print('baseScale : $baseScale');
  }

  Future<void> _handleScaleUpdate(ScaleUpdateDetails details) async {
    // When there are not exactly two fingers on screen don't scale
    if (pointers == 2) {
      await widget.cameraState.setZoomLevel(baseScale * details.scale);
    }
  }

  Future<void> onViewFinderTap(
    TapDownDetails details,
    BoxConstraints constraints,
  ) async {
    final offset = Offset(
      details.localPosition.dx / constraints.maxWidth,
      details.localPosition.dy / constraints.maxHeight,
    );
    await widget.cameraState.setFocusPoint(offset);
  }
}
