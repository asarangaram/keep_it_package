import 'dart:io';
import 'dart:math';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

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
    return ref.watch(videoControllerProvider(path)).when(
          loading: () => const Center(
            child: CircularProgressIndicator(),
          ),
          error: (_, __) => CLErrorView(errorMessage: _.toString()),
          data: (controller) {
            return GestureDetector(
              onTap: () {
                // If the video is playing, pause it.
                if (controller.value.isPlaying) {
                  controller.pause();
                } else {
                  // If the video is paused, play it.
                  controller
                    ..setVolume(0.1)
                    ..play();
                }
              },
              child: SizedBox(
                height: isPlayingFullScreen
                    ? null
                    : min(
                        controller.value.size.height,
                        MediaQuery.of(context).size.height * 0.7,
                      ),
                child: AspectRatio(
                  aspectRatio: aspectRatio ?? controller.value.aspectRatio,
                  child: Stack(
                    children: [
                      VideoPlayer(controller),
                      Center(
                        child: VideoController(controller: controller),
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
            );
          },
        );
  }
}

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
});

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

final videoControllerProvider = FutureProvider.family
    .autoDispose<VideoPlayerController, String>((ref, path) async {
  final controller = VideoPlayerController.file(
    File(path),
  );
  await controller.initialize();

  ref.onDispose(() {
    controller
      ..pause()
      ..dispose();
  });

  return controller;
});
