import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import 'models/camera_state.dart';

mixin CameraControl<T extends StatefulWidget> on State<T> {
  void onAppLifecycleStateChange({
    required AppLifecycleState appState,
    required CameraDescription description,
    required CameraState? cameraState,
    required void Function(CameraState? cameraState) updateCameraState,
    required void Function(String) onCameraError,
  }) {
    if (appState == AppLifecycleState.inactive) {
      cameraState?.dispose();
      updateCameraState(null);
    } else if (appState == AppLifecycleState.resumed) {
      if (cameraState == null) {
        CameraState.createAsync(
          description,
          onCameraStateReady: updateCameraState,
          onCameraError: onCameraError,
        );
      } else {
        // Does this required?
        cameraState.controller
            .setDescription(cameraState.controller.description);
      }
    }
  }
}
