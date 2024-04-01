import 'package:camera/camera.dart';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import '../extensions.dart';

class FlashControl extends StatelessWidget {
  const FlashControl({required this.controller, super.key});
  final CameraController controller;

  @override
  Widget build(BuildContext context) {
    return CLButtonIconLabelled.small(
      switch (controller.value.flashMode) {
        FlashMode.off => Icons.flash_off,
        FlashMode.auto => Icons.flash_auto,
        FlashMode.always => Icons.flash_on,
        FlashMode.torch => Icons.highlight,
      },
      switch (controller.value.flashMode) {
        FlashMode.off => 'Off',
        FlashMode.auto => 'Auto',
        FlashMode.always => 'On',
        FlashMode.torch => 'Torch',
      },
      color: switch (controller.value.flashMode) {
        FlashMode.off => Colors.white,
        FlashMode.auto => Colors.amber,
        FlashMode.always => Colors.amber,
        FlashMode.torch => Colors.amber,
      },
      onTap: () async {
        var currentFlashMode = controller.value.flashMode;
        var success = false;
        for (var i = 0; i < FlashMode.values.length; i++) {
          if (!success) {
            try {
              await controller.setFlashMode(
                FlashMode.values.next(currentFlashMode),
              );
              success = true;
              break;
            } catch (e) {
              currentFlashMode =
                  FlashMode.values.next(controller.value.flashMode);
            }
          }
        }
      },
    );
  }
}
