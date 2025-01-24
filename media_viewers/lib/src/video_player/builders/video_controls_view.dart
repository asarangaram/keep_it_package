/// Referenced from https://pub.dev/packages/video_controls
///
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import 'audio_control_builder.dart';
import '../models/cl_icons.dart';
import '../models/ext_duration.dart';
import '../providers/video_player_state.dart';

class VideoControlsView extends ConsumerStatefulWidget {
  const VideoControlsView({
    required this.controller,
    this.onHover,
    super.key,
  });

  final VideoPlayerController controller;
  final VoidCallback? onHover;

  @override
  VideoControlsState createState() => VideoControlsState();
}

class VideoControlsState extends ConsumerState<VideoControlsView> {
  VideoPlayerValue get video => widget.controller.value;
  double? seekValue;

  Duration get bufferedPosition =>
      video.buffered.isEmpty ? Duration.zero : video.buffered.last.end;

  String get timestamp {
    final isLive = durationToDouble(video.duration) > 10 * 60 * 60;
    final currentPosition =
        seekValue == null ? video.position : doubleToDuration(seekValue!);

    if (isLive) {
      if (video.isCompleted) {
        return '__ / __';
      }
      return '${currentPosition.timestamp} / __';
    } else {
      return '${currentPosition.timestamp} / ${video.duration.timestamp}';
    }
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
    final isLive =
        durationToDouble(widget.controller.value.duration) > 10 * 60 * 60;
    return IconTheme(
      data: const IconThemeData(color: Colors.white),
      child: Listener(
        onPointerDown: (_) => widget.onHover?.call(),
        onPointerHover: (_) => widget.onHover?.call(),
        child: ColoredBox(
          color: const Color.fromRGBO(0, 0, 0, 0.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              if (!isLive)
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
                )
              else ...[
                if (!video.isCompleted) ...[
                  const Padding(
                    padding: EdgeInsets.all(2),
                    child: Text(
                      'The video is still buffering on the server. '
                      'Playback may experience some interruptions.',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  SizedBox(
                    height: 4,
                    child: (video.isBuffering)
                        ? const LinearProgressIndicator(
                            backgroundColor: Colors.red,
                          )
                        : null,
                  ),
                ],
              ],
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      video.isPlaying
                          ? videoPlayerIcons.playerPause
                          : videoPlayerIcons.playerPlay,
                    ),
                    onPressed: onPlayPause,
                  ),
                  AudioControlBuilder(
                    controller: widget.controller,
                    builder: (volume) => Icon(
                      volume == 0
                          ? videoPlayerIcons.audioMuted
                          : videoPlayerIcons.audioUnmuted,
                    ),
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
    if (widget.controller.value.isCompleted) {
      final isLive = durationToDouble(video.duration) > 10 * 60 * 60;
      if (isLive) {
        ref
            .read(videoPlayerStateProvider.notifier)
            .resetVideo(forced: true)
            .then((val) => widget.controller.play());
      }
    }

    // If the video is playing, pause it.
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
  }
}
