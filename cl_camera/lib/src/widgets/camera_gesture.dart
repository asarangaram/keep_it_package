import 'package:flutter/material.dart';

class CameraGesture extends StatefulWidget {
  const CameraGesture({
    required this.currentZoomLevel,
    required this.onChangeZoomLevel,
    super.key,
  });
  final double currentZoomLevel;
  final void Function(double scale) onChangeZoomLevel;

  @override
  State<CameraGesture> createState() => _CameraGestureState();
}

class _CameraGestureState extends State<CameraGesture> {
  int pointers = 0;
  double baseScale = 1;
  @override
  Widget build(BuildContext context) {
    final currentScale = widget.currentZoomLevel;

    return Listener(
      onPointerDown: (_) => pointers++,
      onPointerUp: (_) => pointers--,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onScaleStart: (_) => baseScale = currentScale,
        onScaleUpdate: (details) {
          if (pointers == 2) {
            widget.onChangeZoomLevel(baseScale * details.scale);
          }
        },
      ),
    );
  }
}
