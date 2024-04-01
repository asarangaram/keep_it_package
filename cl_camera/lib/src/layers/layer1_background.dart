import 'dart:ui';

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
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 100, sigmaY: 100),
            child: Container(
              color: Colors.black.withOpacity(
                0.5,
              ), // Adjust opacity as needed
            ),
          ),
        ),
      ],
    );
  }
}
