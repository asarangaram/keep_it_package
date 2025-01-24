import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_viewers/src/video_player/views/get_video_controller.dart';
import 'package:video_player/video_player.dart';

import '../builders/video_controls_view.dart';
import '../models/video_player_state.dart';

class VideoDefaultControls extends ConsumerWidget {
  const VideoDefaultControls({
    required this.uri,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final Uri uri;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetVideoControllerWithState(
      builder: (
        VideoPlayerState state,
        VideoPlayerController controller,
      ) {
        if (state.path == uri) {
          return VideoControlsView(controller: controller);
        } else {
          return const SizedBox.shrink();
        }
      },
      errorBuilder: (message, e) {
        return const SizedBox.shrink();
      },
      loadingBuilder: SizedBox.shrink,
    );
  }
}
