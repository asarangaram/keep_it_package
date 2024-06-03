import 'package:camera/camera.dart';

import 'package:flutter/material.dart';

import 'cl_circular_button.dart';

class FlashControl extends StatelessWidget {
  const FlashControl({required this.controller, super.key});
  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return CircularButton(
      icon: switch (controller.value.flashMode) {
        FlashMode.off => Icons.flash_off,
        FlashMode.auto => Icons.flash_auto,
        FlashMode.always => Icons.flash_on,
        FlashMode.torch => Icons.highlight,
      },
      size: 32,
      hasDecoration: false,
      foregroundColor: switch (controller.value.flashMode) {
        FlashMode.off => Theme.of(context).colorScheme.primary,
        FlashMode.auto => Theme.of(context).colorScheme.primary,
        FlashMode.always => Theme.of(context).colorScheme.primary,
        FlashMode.torch => Theme.of(context).colorScheme.primary,
      },
      onPressed: () async {
        var currentFlashMode = controller.value.flashMode;
        var success = false;
        for (var i = 0; i < FlashMode.values.length; i++) {
          if (!success) {
            try {
              await controller.setFlashMode(
                flashModeNext(currentFlashMode),
              );
              success = true;
              break;
            } catch (e) {
              currentFlashMode = flashModeNext(controller.value.flashMode);
            }
          }
        }
      },
    );
  }

  FlashMode flashModeNext(FlashMode currentFlashMode) {
    return switch (currentFlashMode) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.always,
      FlashMode.always => FlashMode.off,
      FlashMode.torch => throw Exception("TorchMode can't be used for Camera"),
    };
  }
}
