import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class CameraSelect extends StatelessWidget with CameraMixin {
  const CameraSelect({
    required this.cameras,
    required this.currentCamera,
    required this.onNextCamera,
    super.key,
  });
  final List<CameraDescription> cameras;
  final CameraDescription currentCamera;
  final void Function() onNextCamera;

  @override
  Widget build(BuildContext context) {
    return CLButtonIconLabelled.small(
      currentCamera.lensDirection == CameraLensDirection.front
          ? Icons.camera_front
          : Icons.camera_rear,
      getCameraName(
        cameras,
        currentCamera,
      ),
      onTap: onNextCamera,
      color: Colors.white,
    );
  }
}

mixin CameraMixin {
  String getCameraName(
    List<CameraDescription> cameras,
    CameraDescription description,
  ) {
    final directionCameras = cameras
        .where((element) => element.lensDirection == description.lensDirection)
        .toList();

    if (directionCameras.length == 1) {
      return description.lensDirection.name.capitalizeFirstLetter();
    } else {
      return '${description.lensDirection.name.capitalizeFirstLetter()}'
          '-${directionCameras.indexOf(description)}';
    }
  }

  String getResolutionString(Size? previewSize) {
    if (previewSize == null) return 'Unknown';
    return '${previewSize.width.toInt()}x${previewSize.height.toInt()}';
  }
}
