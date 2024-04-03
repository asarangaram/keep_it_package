import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CameraGesture extends ConsumerStatefulWidget {
  const CameraGesture({
    required this.currentZoomLevel,
    required this.onChangeZoomLevel,
    super.key,
  });
  final double currentZoomLevel;
  final void Function(double scale) onChangeZoomLevel;

  @override
  ConsumerState<CameraGesture> createState() => _CameraGestureState();
}

class _CameraGestureState extends ConsumerState<CameraGesture> {
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
