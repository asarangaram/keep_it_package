import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../get_cameras.dart';
import '../models/camera_settings.dart';
import '../models/camera_state.dart';

class CameraControllerNotifier extends StateNotifier<AsyncValue<CameraState>> {
  CameraControllerNotifier(this.ref) : super(const AsyncValue.loading()) {
    init();
  }
  final Ref ref;
  late final CameraController cameraController;
  Future<void> init() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final cameras = await ref.read(camearasProvider.future);
      const initialSettings = CameraSettings();
      cameraController = CameraController(
        cameras[1],
        ResolutionPreset.ultraHigh,
        enableAudio: initialSettings.enableAudio,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await cameraController.initialize();
      final minAvailableZoom = await cameraController.getMinZoomLevel();
      final maxAvailableZoom = await cameraController.getMaxZoomLevel();

      final cameraState = CameraState(
        cameras: cameras,
        cameraSettings: initialSettings,
        cameraController: cameraController,
      );

      cameraController.addListener(controllerListener);

      return cameraState;
    });
  }

  void controllerListener() {
    try {
      if (cameraController.value.hasError) {
        throw Exception(cameraController.value.errorDescription);
      }
    } catch (e, st) {
      state = AsyncError<CameraState>(e, st);
    }
  }

  @override
  void dispose() {
    cameraController
      ..removeListener(controllerListener)
      ..dispose();
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
  ref.watch(camearasProvider);
  final notifier = CameraControllerNotifier(ref);

  return notifier;
});
