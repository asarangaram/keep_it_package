import 'package:camera/camera.dart';
import 'package:cl_camera/cl_camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camerasAsync = ref.watch(camerasProvider);
    // TODO(anandas): Read these values from settings
    const defaultFrontCameraIndex = 0;
    const defaultBackCameraIndex = 0;

    return camerasAsync.when(
      data: (cameras) => FutureBuilder(
        future: getApplicationCacheDirectory(),
        builder: (context, snapShot) {
          if (snapShot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (snapShot.hasData && snapShot.data != null) {
            return CameraScreen(
              cameras: [
                cameras
                    .where((e) => e.lensDirection == CameraLensDirection.front)
                    .toList()[defaultFrontCameraIndex],
                cameras
                    .where((e) => e.lensDirection == CameraLensDirection.back)
                    .toList()[defaultBackCameraIndex],
              ],
              directory: snapShot.data!.path,
            );
          }
          return CLErrorView(errorMessage: snapShot.error.toString());
        },
      ),
      error: (e, st) => CLErrorView(errorMessage: e.toString()),
      loading: CLLoadingView.new,
    );
  }
}

final camerasProvider = FutureProvider<List<CameraDescription>>((ref) async {
  return availableCameras();
});
