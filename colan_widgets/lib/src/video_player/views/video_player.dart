import 'dart:async';
import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../models/video_player_state.dart';
import '../providers/video_player_state.dart';
import 'video_controls.dart';

class CLVideoPlayer extends ConsumerStatefulWidget {
  const CLVideoPlayer({
    required this.path,
    required this.isPlayingFullScreen,
    required this.onTapFullScreen,
    super.key,
    this.maxHeight,
    this.onFocus,
  });
  final String path;

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
    final path = widget.path;

    return ref.watch(videoPlayerStateProvider(path)).when(
          loading: () => const SizedBox(
            height: 128,
            child: Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (_, __) {
            return SizedBox(
              height: 128,
              child: CLErrorView(errorMessage: _.toString()),
            );
          },
          data: (VideoPlayerState playerState) {
            final controller = playerState.controller;
            return VisibilityDetector(
              key: ValueKey(path),
              onVisibilityChanged: (info) {
                if (context.mounted) {
                  if (info.visibleFraction == 0.0) {
                    ref
                        .read(videoPlayerStateProvider(path).notifier)
                        .inactive();
                  } else {
                    ref.read(videoPlayerStateProvider(path).notifier).active();
                  }
                }
              },
              child: SizedBox(
                height: widget.isPlayingFullScreen
                    ? null
                    : min(
                        playerState.controller!.value.size.height,
                        widget.maxHeight ??
                            MediaQuery.of(context).size.height * 0.7,
                      ),
                child: GestureDetector(
                  onTap: () {
                    if (playerState.paused) {
                      ref
                          .read(
                            videoPlayerStateProvider(playerState.path).notifier,
                          )
                          .play();
                      // Call only once
                      if (!isFocussed) {
                        setState(() {
                          isFocussed = true;
                        });
                        widget.onFocus?.call();
                      }
                    } else {
                      ref
                          .read(
                            videoPlayerStateProvider(playerState.path).notifier,
                          )
                          .pause();
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
                        () => setState(() => isHovering = false),
                      );
                    },
                    onPointerHover: (_) {
                      setState(() => isHovering = true);
                      disableControls?.cancel();
                      disableControls = Timer(
                        const Duration(seconds: 2),
                        () => setState(() => isHovering = false),
                      );
                    },
                    child: AspectRatio(
                      aspectRatio: controller!.value.aspectRatio,
                      child: Stack(
                        alignment: AlignmentDirectional.bottomCenter,
                        children: [
                          VideoPlayer(controller),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 500),
                            child: (isHovering || playerState.paused)
                                ? VideoControls(
                                    playerState: playerState,
                                    onTapFullScreen: widget.onTapFullScreen,
                                    isPlayingFullScreen:
                                        widget.isPlayingFullScreen,
                                  )
                                : Container(),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
  }
}
