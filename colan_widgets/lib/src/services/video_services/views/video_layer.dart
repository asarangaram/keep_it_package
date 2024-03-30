import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../providers/show_controls.dart';
import 'video_controls.dart';

class VideoLayer extends ConsumerWidget {
  const VideoLayer({
    required this.controller,
    this.fit,
    this.isPlayingFullScreen = false,
    this.onTapFullScreen,
    super.key,
    this.children,
  });
  final VideoPlayerController controller;

  final void Function()? onTapFullScreen;
  final bool isPlayingFullScreen;
  final BoxFit? fit;
  final List<Widget>? children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControl = ref.watch(showControlsProvider);

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
      child: AspectRatio(
        aspectRatio: controller.value.aspectRatio,
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            VideoPlayer(controller),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: showControl
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (children != null) ...children!,
                        VideoControls(
                          controller: controller,
                          onTapFullScreen: onTapFullScreen,
                          isPlayingFullScreen: isPlayingFullScreen,
                        ),
                      ],
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}
