import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../get_cameras.dart';
import '../models/camera_settings.dart';
import '../models/camera_state.dart';

class CameraControllerNotifier extends StateNotifier<AsyncValue<CameraState>> {
  CameraControllerNotifier(this.cameras) : super(const AsyncValue.loading()) {
    cameras.whenOrNull(data: init);
  }
  AsyncValue<List<CameraDescription>> cameras;

  Future<void> init(List<CameraDescription> cameras) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      const initialSettings = CameraSettings();
      final cameraController = CameraController(
        cameras[initialSettings.cameraIndex],
        initialSettings.resolutionPreset,
        enableAudio: initialSettings.enableAudio,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await cameraController.initialize();
      final minAvailableZoom = await cameraController.getMinZoomLevel();
      final maxAvailableZoom = await cameraController.getMaxZoomLevel();

      final cameraState = CameraState(
        cameras: cameras,
        cameraSettings: initialSettings.copyWith(
          minAvailableZoom: minAvailableZoom,
          maxAvailableZoom: maxAvailableZoom,
        ),
        cameraController: cameraController,
      );

      cameraController.addListener(controllerListener);

      return cameraState;
    });
  }

  void controllerListener() {
    state.whenOrNull(
      data: (cameraState) async {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() async {
          if (cameraState.cameraController.value.hasError) {
            throw Exception(
              cameraState.cameraController.value.errorDescription,
            );
          }
          return cameraState;
        });
      },
    );
  }

  @override
  void dispose() {
    state.whenOrNull(
      data: (cameraState) async {
        cameraState.cameraController.removeListener(controllerListener);
        await cameraState.cameraController.dispose();
      },
    );
    super.dispose();
  }

  set zoomLevel(double value) {
    state.whenOrNull(
      data: (cameraState) async {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() async {
          return cameraState.zoomLevel(value);
        });
      },
    );
  }

  double get zoomLevel => 0;
}

final cameraControllerProvider =
    StateNotifierProvider<CameraControllerNotifier, AsyncValue<CameraState>>(
        (ref) {
  final camerasAsync = ref.watch(camearasProvider);
  final notifier = CameraControllerNotifier(camerasAsync);

  return notifier;
});
