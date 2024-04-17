import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/camera_provider.dart';

class GetCameras extends ConsumerWidget {
  const GetCameras({required this.builder, super.key});
  final Widget Function({
    required CameraDescription frontCamera,
    required CameraDescription backCamera,
  }) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO(anandas): Read these values from settings
    const defaultFrontCameraIndex = 0;
    const defaultBackCameraIndex = 0;
    final camerasAsync = ref.watch(camerasProvider);
    return camerasAsync.when(
      data: (cameras) {
        return builder(
          frontCamera: cameras
              .where(
                (e) => e.lensDirection == CameraLensDirection.front,
              )
              .toList()[defaultFrontCameraIndex],
          backCamera: cameras
              .where(
                (e) => e.lensDirection == CameraLensDirection.back,
              )
              .toList()[defaultBackCameraIndex],
        );
      },
      error: (e, st) => CLErrorView(errorMessage: e.toString()),
      loading: CLLoadingView.new,
    );
  }
}
