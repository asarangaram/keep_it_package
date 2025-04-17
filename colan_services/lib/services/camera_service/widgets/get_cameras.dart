import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/camera_provider.dart';
import '../../basic_page_service/widgets/cl_error_view.dart';

class GetCameras extends ConsumerWidget {
  const GetCameras({required this.builder, super.key});
  final Widget Function({
    required List<CameraDescription> cameras,
  }) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final camerasAsync = ref.watch(camerasProvider);

    return camerasAsync.when(
      data: (cameras) {
        return builder(cameras: cameras);
      },
      error: (e, st) => CLErrorView(errorMessage: e.toString()),
      loading: () => CLLoader.widget(
        debugMessage: 'camerasAsync',
      ),
    );
  }
}
