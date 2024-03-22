import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/camera_state.dart';

class CameraPreviewCore extends ConsumerWidget {
  const CameraPreviewCore({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller =
        ref.watch(cameraStateProvider.select((value) => value.controller));
    return controller.buildPreview();
  }
}
