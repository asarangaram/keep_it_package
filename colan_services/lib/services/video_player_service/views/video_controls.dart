/// Referenced from https://pub.dev/packages/video_controls
///
library;

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../builders/audio_control_builder.dart';
import '../providers/show_controls.dart';

class VideoControls extends ConsumerStatefulWidget {
  const VideoControls({
    required this.controller,
    super.key,
  });

  final VideoPlayerController controller;

  @override
  VideoControlsState createState() => VideoControlsState();
}

class VideoControlsState extends ConsumerState<VideoControls> {
  VideoPlayerValue get video => widget.controller.value;
  double? seekValue;

  Duration get bufferedPosition =>
      video.buffered.isEmpty ? Duration.zero : video.buffered.last.end;

  String get timestamp {
    final currentPosition =
        seekValue == null ? video.position : doubleToDuration(seekValue!);
    return '${currentPosition.timestamp} / ${video.duration.timestamp}';
  }

  /// Updates the value of [video] whenever the controller updates.
  void listener() => setState(() {});

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(listener);
  }

  @override
  void dispose() {
    widget.controller.removeListener(listener);
    super.dispose();
  }

  /// Converts a [Duration] object to a double.
  ///
  /// Used to allow a [Duration] object to be used with a [Slider].
  double durationToDouble(Duration duration) => duration.inSeconds.toDouble();

  /// Converts a double to a [Duration] object.
  ///
  /// This allows a [Slider] to output [Duration] values.
  Duration doubleToDuration(double position) =>
      Duration(minutes: position ~/ 60, seconds: (position % 60).truncate());

  @override
  Widget build(BuildContext context) {
    return IconTheme(
      data: const IconThemeData(color: Colors.white),
      child: Listener(
        onPointerDown: (_) {
          ref
              .read(showControlsProvider.notifier)
              .briefHover(timeout: const Duration(seconds: 5));
        },
        onPointerHover: (_) {
          ref
              .read(showControlsProvider.notifier)
              .briefHover(timeout: const Duration(seconds: 5));
        },
        child: ColoredBox(
          color: const Color.fromRGBO(0, 0, 0, 0.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Material(
                color: Colors.transparent,
                child: Stack(
                  children: [
                    // required only for network
                    SliderTheme(
                      data: SliderThemeData(
                        thumbShape: SliderComponentShape.noThumb,
                      ),
                      child: Slider(
                        max: durationToDouble(video.duration),
                        value: durationToDouble(bufferedPosition),
                        onChanged: null,
                      ),
                    ),
                    Slider(
                      max: durationToDouble(video.duration),
                      value: seekValue ?? durationToDouble(video.position),
                      onChanged: (double value) =>
                          setState(() => seekValue = value),
                      onChangeEnd: (double value) {
                        setState(() => seekValue = null);
                        widget.controller.seekTo(doubleToDuration(value));
                      },
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      video.isPlaying ? Icons.pause : Icons.play_arrow,
                    ),
                    onPressed: onPlayPause,
                  ),
                  AudioControlBuilder(
                    controller: widget.controller,
                    builder: (volume) =>
                        Icon(volume == 0 ? Icons.volume_off : Icons.volume_up),
                  ),
                  const Spacer(),
                  Flexible(
                    child: FittedBox(
                      child: Text(
                        timestamp,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void onPlayPause() {
    // If the video is playing, pause it.
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
  }
}
