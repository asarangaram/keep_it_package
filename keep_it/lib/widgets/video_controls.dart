import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../models/video_player_state.dart';
import '../providers/video_player_state.dart';

extension on Duration {
  String get timestamp => "${inMinutes.toString().padLeft(2, '0')}:"
      "${(inSeconds % 60).toString().padLeft(2, '0')}";
}

class VideoControls extends ConsumerStatefulWidget {
  const VideoControls({
    required this.playerState,
    required this.isPlayingFullScreen,
    super.key,
    this.onTapFullScreen,
  });

  final VideoPlayerState playerState;
  final void Function()? onTapFullScreen;
  final bool isPlayingFullScreen;

  @override
  VideoControlsState createState() => VideoControlsState();
}

class VideoControlsState extends ConsumerState<VideoControls> {
  VideoPlayerValue get video => widget.playerState.controller!.value;
  double? seekValue;
  double volume = 1;

  Duration get bufferedPosition =>
      video.buffered.isEmpty ? Duration.zero : video.buffered.last.end;

  bool get isMuted => video.volume == 0;

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
    widget.playerState.controller!.addListener(listener);
  }

  @override
  void dispose() {
    widget.playerState.controller!.removeListener(listener);
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
  Widget build(BuildContext context) => IconTheme(
        data: const IconThemeData(color: Colors.white),
        child: ColoredBox(
          color: const Color.fromRGBO(0, 0, 0, 0.5),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Stack(
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
                      widget.playerState.controller!
                          .seekTo(doubleToDuration(value));
                    },
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon:
                        Icon(video.isPlaying ? Icons.pause : Icons.play_arrow),
                    onPressed: () =>
                        onPlayPause(context, ref, widget.playerState),
                  ),
                  IconButton(
                    icon: Icon(isMuted ? Icons.volume_off : Icons.volume_up),
                    onPressed: () =>
                        onMuteToggle(context, ref, widget.playerState),
                  ),
                  Flexible(
                    child: Slider(
                      value: widget.playerState.controller!.value.volume,
                      onChanged: (value) => onAdjustVolume(
                        context,
                        ref,
                        widget.playerState,
                        value,
                      ),
                      onChangeEnd: (value) => onAdjustVolume(
                        context,
                        ref,
                        widget.playerState,
                        value,
                      ),
                    ),
                  ),
                  Text(
                    timestamp,
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white),
                  ),
                  IconButton(
                    icon: Icon(
                      widget.isPlayingFullScreen
                          ? Icons.close_fullscreen_outlined
                          : Icons.fullscreen_outlined,
                    ),
                    onPressed: widget.onTapFullScreen,
                  ),
                ],
              ),
            ],
          ),
        ),
      );

  void onAdjustVolume(
    BuildContext context,
    WidgetRef ref,
    VideoPlayerState playerState,
    double value,
  ) {
    playerState.controller!.setVolume(value);
    volume = value;
    setState(() {});
  }

  void onMuteToggle(
    BuildContext context,
    WidgetRef ref,
    VideoPlayerState playerState,
  ) =>
      playerState.controller!.setVolume(isMuted ? volume : 0);

  void onPlayPause(
    BuildContext context,
    WidgetRef ref,
    VideoPlayerState playerState,
  ) {
    // If the video is playing, pause it.
    if (playerState.paused) {
      ref
          .read(
            videoPlayerStateProvider(playerState.path).notifier,
          )
          .play();
    } else {
      ref
          .read(
            videoPlayerStateProvider(playerState.path).notifier,
          )
          .pause();
    }
  }
}
