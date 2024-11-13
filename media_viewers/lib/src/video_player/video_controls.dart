import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:media_viewers/src/video_player/get_video_controller.dart';
import 'package:video_player/video_player.dart';

import '../../video_player_service/models/video_player_state.dart';
import 'views/video_controls_view.dart';

class VideoDefaultControls extends ConsumerWidget {
  const VideoDefaultControls({
    required this.uri,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final Uri uri;
  final Widget Function(Object errorMessage, StackTrace error) errorBuilder;
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
          return Container();
        }
      },
      errorBuilder: (message, e) {
        return Container();
      },
      loadingBuilder: () {
        return Container();
      },
    );
  }
}
