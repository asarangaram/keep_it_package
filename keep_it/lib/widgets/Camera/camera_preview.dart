import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'camera_gesture.dart';
import 'camera_preview_core.dart';
import 'capture_controls.dart';
import 'providers/camera_state.dart';

class CameraPreviewWidget extends ConsumerWidget {
  const CameraPreviewWidget({
    this.children = const [],
    super.key,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.watch(cameraStateProvider.select((value) => value.controller));

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
              child: const Stack(
                fit: StackFit.expand,
                children: <Widget>[
                  CameraPreviewCore(),
                  CameraGesture(),
                  Align(
                    alignment: Alignment.bottomCenter,
                    // TODO(anandas):   child: CaptureControls(),
                  ),
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
