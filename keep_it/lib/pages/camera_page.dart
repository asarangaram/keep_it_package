import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/widgets/Camera/get_cameras.dart';

import '../widgets/camera.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetCameras(
      builder: (cameras) {
        return CameraView(cameras: cameras);
      },
    );
  }
}
