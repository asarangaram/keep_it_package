/* import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../get_cameras.dart';
import '../models/camera_settings.dart';
import '../models/camera_state.dart';

class CameraStateNotifier extends StateNotifier<AsyncValue<CameraState>> {
  CameraStateNotifier(this.cameras) : super(const AsyncValue.loading()) {
    cameras.whenOrNull(data: init);
  }
  AsyncValue<List<CameraDescription>> cameras;

  Future<void> init(List<CameraDescription> cameras) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      const initialSettings = CameraSettings();
      return create(cameras, cameras[0], initialSettings);
    });
  }

  Future<CameraState> recreate(
    CameraState cameraState,
    List<CameraDescription> cameras,
    CameraSettings settings,
  ) async {
    final newState = await create(cameras, cameras[0], settings);
    unawaited(
      Future<void>.delayed(const Duration(milliseconds: 1), () {
        destroyController(cameraState);
      }),
    );

    return newState;
  }

  Future<CameraState> create(
    List<CameraDescription> cameras,
    CameraDescription currCamera,
    CameraSettings settings,
  ) async {
    final cameraState = CameraState(
      cameras: cameras,
      currentCamera: currCamera,
      cameraSettings: settings,
    );

    
    print('Controller ${cameraState.hashCode} Created');
    return cameraState;
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
    print('Dispose Called');
    state.whenOrNull(
      data: (cameraState) async {
        cameraState.cameraController.removeListener(controllerListener);
        await destroyController(cameraState);
      },
    );
    super.dispose();
  }

  Future<void> destroyController(CameraState cameraState) async {
    print('Controller ${cameraState.hashCode} Disposed');
    cameraState.cameraController.removeListener(controllerListener);
    await cameraState.cameraController.dispose();
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

  void nextResolution() {
    state.whenOrNull(
      data: (cameraState) async {
        state = const AsyncValue.loading();
        state = await AsyncValue.guard(() async {
          final newSettings = cameraState.cameraSettings.nextResolution();

          return recreate(cameraState, cameraState.cameras, newSettings);
        });
      },
    );
  }

  double get zoomLevel => 0;
}

final cameraStateProvider =
    StateNotifierProvider<CameraControllerNotifier, AsyncValue<CameraState>>(
        (ref) {
  final camerasAsync = ref.watch(camearasProvider);
  final notifier = CameraControllerNotifier(camerasAsync);

  return notifier;
});
 */
