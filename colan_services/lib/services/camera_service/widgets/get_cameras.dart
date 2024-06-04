// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:camera/camera.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/camera_provider.dart';

class GetCameras extends ConsumerStatefulWidget {
  const GetCameras({required this.builder, super.key});
  final Widget Function({
    required List<CameraDescription> cameras,
  }) builder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _GetCamerasState();
}

class _GetCamerasState extends ConsumerState<GetCameras> {
  @override
  Widget build(BuildContext context) {
    final camerasAsync = ref.watch(camerasProvider);

    return camerasAsync.when(
      data: (cameras) {
        return widget.builder(cameras: cameras);
      },
      error: (e, st) => CLErrorView(errorMessage: e.toString()),
      loading: CLLoadingView.new,
    );
  }
}
