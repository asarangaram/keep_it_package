import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/Camera/get_cameras.dart';
import '../widgets/camera.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FullscreenLayout(
      child: GetCameras(builder: (cameras) => CameraView(cameras: cameras)),
    );
  }
}
