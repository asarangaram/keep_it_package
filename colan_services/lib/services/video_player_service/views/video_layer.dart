import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../providers/show_controls.dart';

class VideoLayer extends ConsumerWidget {
  const VideoLayer({
    required this.controller,
    super.key,
  });
  final VideoPlayerController controller;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onDoubleTap: () {
        if (controller.value.isPlaying) {
          ref
              .read(showControlsProvider.notifier)
              .briefHover(timeout: const Duration(seconds: 3));
          controller.pause();
        } else {
          ref
              .read(showControlsProvider.notifier)
              .briefHover(timeout: const Duration(seconds: 1));
          controller.play();
        }
      },
      onTap: () {
        if (controller.value.isPlaying) {
          ref
              .read(showControlsProvider.notifier)
              .briefHover(timeout: const Duration(seconds: 3));
          // controller.pause();
        } else {
          ref
              .read(showControlsProvider.notifier)
              .briefHover(timeout: const Duration(seconds: 1));
          controller.play();
        }
      },
      child: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: Align(
            alignment: AlignmentDirectional.bottomCenter,
            child: VideoPlayer(controller),
          ),
        ),
      ),
    );
  }
}
