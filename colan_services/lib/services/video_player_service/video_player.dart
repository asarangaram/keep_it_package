import 'package:colan_services/services/video_player_service/views/get_video_controller.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'models/video_player_state.dart';
import 'providers/video_player_state.dart';
import 'views/video_controls.dart';
import 'views/video_layer.dart';

class VideoPlayerService extends ConsumerWidget {
  const VideoPlayerService.player({
    required this.media,
    required this.alternate,
    super.key,
    this.onSelect,
    this.autoStart = false,
  }) : isPlayer = true;
  const VideoPlayerService.controlMenu({
    required this.media,
    super.key,
  })  : alternate = null,
        onSelect = null,
        autoStart = false,
        isPlayer = false;

  final CLMedia media;
  final void Function()? onSelect;
  final bool autoStart;
  final Widget? alternate;
  final bool isPlayer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isPlayer && autoStart) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (context.mounted) {
          await ref
              .read(videoPlayerStateProvider.notifier)
              .playVideo(media.path);
        }
      });
    }

    return GetVideoController(
      builder: (
        VideoPlayerState state,
        VideoPlayerController controller,
      ) {
        if (state.path == media.path) {
          if (!isPlayer) {
            return VideoControls(controller: controller);
          }
          return VideoLayer(
            controller: controller,
          );
        } else {
          if (!isPlayer) return Container();
          return GestureDetector(
            onTap: onSelect,
            child: alternate,
          );
        }
      },
      errorBuilder: (message, e) {
        if (!isPlayer) return Container();
        return GestureDetector(
          onTap: onSelect,
          child: alternate,
        );
      },
      loadingBuilder: () {
        if (!isPlayer) return Container();
        return Stack(
          children: [
            if (alternate != null) alternate!,
            const Center(child: CircularProgressIndicator()),
          ],
        );
      },
    );
  }
}
