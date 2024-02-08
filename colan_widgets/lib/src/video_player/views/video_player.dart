import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'video_controls.dart';

class CLVideoPlayer extends ConsumerStatefulWidget {
  const CLVideoPlayer({
    required this.controller,
    this.isPlayingFullScreen = false,
    this.onTapFullScreen,
    super.key,
    this.maxHeight,
    this.onFocus,
  });
  final VideoPlayerController controller;

  final void Function()? onTapFullScreen;
  final bool isPlayingFullScreen;
  final double? maxHeight;
  final void Function()? onFocus;

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
    return SizedBox(
      height: widget.isPlayingFullScreen
          ? null
          : min(
              controller.value.size.height,
              widget.maxHeight ?? MediaQuery.of(context).size.height * 0.7,
            ),
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
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: Stack(
            alignment: AlignmentDirectional.bottomCenter,
            children: [
              VideoPlayer(controller),
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
      ),
    );
  }
}
