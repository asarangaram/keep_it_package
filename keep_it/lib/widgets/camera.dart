import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'Camera/get_cameras.dart';
import 'Camera/providers/camera_state.dart';
import 'camera_screen.dart';

class CameraView extends ConsumerWidget {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cameraStateAsync = ref.watch(cameraControllerProvider);
    return FullscreenLayout(
      useSafeArea: false,
      child: cameraStateAsync.when(
        error: (e, st) => CameraError(errorMessage: e.toString()),
        loading: CameraLoading.new,
        data: (cameraState) => CameraInterface(
          cameraController: cameraState.cameraController,
        ),
      ),
    );
  }
}
