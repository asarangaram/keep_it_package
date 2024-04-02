import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraBackgroundLayer extends StatelessWidget {
  const CameraBackgroundLayer({
    required this.controller,
    super.key,
  });

  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        controller.buildPreview(),
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.onSurface.withAlpha(128 + 32),
            ),
          ),
        ),
      ],
    );
  }
}
