import 'dart:math';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../models/video_player_state.dart';
import '../providers/video_player_state.dart';

class VideoPlayerScreen extends ConsumerWidget {
  const VideoPlayerScreen({
    required this.path,
    required this.isPlayingFullScreen,
    super.key,
    this.aspectRatio,
    this.fullScreenControl,
  });
  final String path;
  final double? aspectRatio;
  final Widget? fullScreenControl;
  final bool isPlayingFullScreen;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                height: isPlayingFullScreen
                    ? null
                    : min(
                        playerState.controller!.value.size.height,
                        MediaQuery.of(context).size.height * 0.7,
                      ),
                child: GestureDetector(
                  onTap: () {
                    // If the video is playing, pause it.
                    if (playerState.paused) {
                      ref.read(videoPlayerStateProvider(path).notifier).play();
                    } else {
                      ref.read(videoPlayerStateProvider(path).notifier).pause();
                    }
                  },
                  child: AspectRatio(
                    aspectRatio: aspectRatio ?? controller!.value.aspectRatio,
                    child: Stack(
                      children: [
                        VideoPlayer(controller!),
                        Center(
                          child: VideoController(playerState: playerState),
                        ),
                        if (fullScreenControl != null)
                          Positioned(
                            bottom: 8,
                            right: 8,
                            child: fullScreenControl!,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        );
  }
}

class VideoController extends ConsumerWidget {
  const VideoController({required this.playerState, super.key});
  final VideoPlayerState playerState;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (playerState.paused) {
      return const CLIcon.veryLarge(
        Icons.play_arrow_rounded,
        color: Colors.white,
      );
    } else {
      return Container();
    }
  }
}
/* 
class VideoController extends StatefulWidget {
  const VideoController({
    required VideoPlayerController controller,
    super.key,
  }) : _controller = controller;

  final VideoPlayerController _controller;

  @override
  State<VideoController> createState() => _VideoControllerState();
}

class _VideoControllerState extends State<VideoController> {
  @override
  void initState() {
    widget._controller.addListener(listener);
    super.initState();
  }

  @override
  void dispose() {
    widget._controller.removeListener(listener);
    super.dispose();
  }

  void listener() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!widget._controller.value.isPlaying) {
      return CLIcon.veryLarge(
        widget._controller.value.isPlaying
            ? Icons.pause_circle_rounded
            : Icons.play_arrow_rounded,
        color: Colors.white,
      );
    } else {
      return Container();
    }
  }
}

final isPlayingProvider = StateProvider<bool>((ref) {
  return false;
}); */

class VidoePlayIcon extends StatelessWidget {
  const VidoePlayIcon({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Theme.of(context)
            .colorScheme
            .onBackground
            .withAlpha(192), // Color for the circular container
      ),
      child: CLIcon.veryLarge(
        Icons.play_arrow_sharp,
        color: Theme.of(context).colorScheme.background.withAlpha(192),
      ),
    );
  }
}
