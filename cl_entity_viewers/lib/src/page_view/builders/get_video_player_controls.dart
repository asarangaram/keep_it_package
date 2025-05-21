import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/video_player_controls.dart';
import '../providers/video_player_state.dart';

class GetVideoPlayerControls extends ConsumerWidget {
  const GetVideoPlayerControls({required this.builder, super.key});
  final Widget Function(
    VideoPlayerControls controls,
  ) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controls = ref.watch(videoPlayerProvider.notifier);
    return builder(controls);
  }
}
