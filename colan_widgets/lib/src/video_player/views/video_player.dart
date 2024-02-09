import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../../models/cl_media.dart';
import '../../views/cl_media_preview.dart';
import '../providers/video_player_state.dart';
import 'video_controls.dart';

class CLVideoPlayer extends ConsumerStatefulWidget {
  const CLVideoPlayer({
    required this.controller,
    this.fit,
    this.isPlayingFullScreen = false,
    this.onTapFullScreen,
    super.key,
  });
  final VideoPlayerController controller;

  final void Function()? onTapFullScreen;
  final bool isPlayingFullScreen;
  final BoxFit? fit;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => CLVideoPlayerState();
}

class CLVideoPlayerState extends ConsumerState<CLVideoPlayer> {
  bool isHovering = false;

  Timer? disableControls;
  bool isFocussed = false;

  @override
  void dispose() {
    disableControls?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    return GestureDetector(
      onTap: () {
        if (controller.value.isPlaying) {
          controller.pause();
        } else {
          controller.play();
        }
      },
      child: Listener(
        behavior: HitTestBehavior.translucent,
        onPointerDown: (_) {
          disableControls?.cancel();
          setState(() {
            isHovering = true;
          });
        },
        onPointerUp: (_) {
          // If the video is playing, pause it.

          disableControls = Timer(
            const Duration(seconds: 3),
            () {
              if (mounted) {
                setState(() => isHovering = false);
              }
            },
          );
        },
        onPointerHover: (_) {
          setState(() => isHovering = true);
          disableControls?.cancel();
          disableControls = Timer(
            const Duration(seconds: 2),
            () {
              if (mounted) {
                setState(() => isHovering = false);
              }
            },
          );
        },
        child: Stack(
          alignment: AlignmentDirectional.bottomCenter,
          children: [
            KeepAspectRatio(
              keepAspectRatio: widget.fit != null,
              aspectRatio: controller.value.aspectRatio,
              child: VideoPlayer(controller),
            ),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: (isHovering || !controller.value.isPlaying)
                  ? VideoControls(
                      controller: controller,
                      onTapFullScreen: widget.onTapFullScreen,
                      isPlayingFullScreen: widget.isPlayingFullScreen,
                    )
                  : Container(),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoViewer extends ConsumerWidget {
  const VideoViewer({required this.media, super.key, this.onSelect});
  final CLMedia media;
  final void Function()? onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(videoPlayerStateProvider);
    Future<void> onTap() async {
      await ref.read(videoPlayerStateProvider.notifier).playVideo(media.path);
      onSelect?.call();
    }

    return switch (state.path == media.path) {
      true => state.controllerAsync.when(
          data: (controller) => CLVideoPlayer(
            controller: controller,
            fit: BoxFit.contain,
          ),
          error: (_, __) => Container(),
          loading: () => VideoPreview(
            media: media,
            videoOverlayChild: const CircularProgressIndicator(),
            /* onTap: onTap,
              overlayChild: , */
          ),
        ),
      false => GestureDetector(
          onTap: onTap,
          child: VideoPreview(
            media: media,
 
            //onTap: onTap,
          ),
        )
    };
  }
}
