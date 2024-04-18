import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/video_player_state.dart';
import '../providers/video_player_state.dart';

class GetVideoController extends ConsumerWidget {
  const GetVideoController({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final Widget Function(
    VideoPlayerState state,
    VideoPlayerController controller,
  ) builder;
  final Widget Function(String errorMessage, dynamic error) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(videoPlayerStateProvider);
    return state.controllerAsync.when(
      data: (controller) => builder(state, controller),
      error: (e, __) => errorBuilder('failed to get controller', e),
      loading: loadingBuilder,
    );
  }
}
