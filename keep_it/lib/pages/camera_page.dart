import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/camera.dart';

class CameraPage extends ConsumerWidget {
  const CameraPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const FullscreenLayout(
      useSafeArea: false,
      child: CameraView(),
    );
  }
}
