import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/camera_state.dart';

class CameraGesture extends ConsumerStatefulWidget {
  const CameraGesture({super.key});

  @override
  ConsumerState<CameraGesture> createState() => _CameraGestureState();
}

class _CameraGestureState extends ConsumerState<CameraGesture> {
  // Counting pointers (number of user fingers on screen)
  int pointers = 0;
  double currentScale = 1;
  double baseScale = 1;
  @override
  Widget build(BuildContext context) {
    final currentScale =
        ref.watch(cameraStateProvider.select((value) => value.currentScale));
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
            onScaleStart: (_) => baseScale = currentScale,
            onScaleUpdate: (details) {
              if (pointers == 2) {
                ref
                    .read(cameraStateProvider.notifier)
                    .setZoomLevel(baseScale * details.scale);
              }
            },
            onTapDown: (TapDownDetails details) {
              final offset = Offset(
                details.localPosition.dx / constraints.maxWidth,
                details.localPosition.dy / constraints.maxHeight,
              );
              ref.read(cameraStateProvider.notifier).setFocusPoint(offset);
            },
          );
        },
      ),
    );
  }
}
