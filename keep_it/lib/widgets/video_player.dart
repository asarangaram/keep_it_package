import 'dart:io';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({
    required this.path,
    super.key,
    this.aspectRatio,
  });
  final String path;
  final double? aspectRatio;
  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;
  late Future<void> Function() _initializeVideoPlayerFuture;

  @override
  void initState() {
    super.initState();

    // Create and store the VideoPlayerController. The VideoPlayerController
    // offers several different constructors to play videos from assets, files,
    // or the internet.
    _controller = VideoPlayerController.file(
      File(widget.path),
    );

    _initializeVideoPlayerFuture = () async => _controller.initialize();
  }

  @override
  void dispose() {
    // Ensure disposing of the VideoPlayerController to free up resources.
    _controller.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Complete the code in the next step.
    // Use a FutureBuilder to display a loading spinner while
    // waiting for the  VideoPlayerController to finish initializing.
    return FutureBuilder(
      future: _initializeVideoPlayerFuture(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          // If the VideoPlayerController has finished initialization, use
          // the data it provides to limit the aspect ratio of the video.
          return Center(
            child: AspectRatio(
              aspectRatio: widget.aspectRatio ?? _controller.value.aspectRatio,
              // Use the VideoPlayer widget to display the video.
              child: GestureDetector(
                onTap: () {
                  // If the video is playing, pause it.
                  if (_controller.value.isPlaying) {
                    _controller.pause();
                  } else {
                    // If the video is paused, play it.
                    _controller
                      ..setVolume(1)
                      ..play();
                  }
                },
                child: Stack(
                  children: [
                    VideoPlayer(_controller),
                    Center(
                      child: VideoController(controller: _controller),
                    ),
                  ],
                ),
              ),
            ),
          );
        } else {
          // If the VideoPlayerController is still initializing, show a
          // loading spinner.
          return const Center(
            child: CircularProgressIndicator(),
          );
        }
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
    widget._controller.addListener(() {
      setState(() {});
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget._controller.value.isPlaying) {
      return CLIcon.veryLarge(
        widget._controller.value.isPlaying
            ? Icons.pause_circle
            : Icons.play_arrow_sharp,
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
