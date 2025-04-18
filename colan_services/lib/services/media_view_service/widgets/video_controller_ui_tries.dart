/* /// Referenced from https://pub.dev/packages/video_controls
///
library;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../builders/audio_control_builder.dart';
import '../models/cl_icons.dart';
import '../models/ext_duration.dart';
import '../providers/video_player_state.dart';

class VideoControlsView extends ConsumerStatefulWidget {
  const VideoControlsView({
    required this.controller,
    this.onHover,
    this.onResetVideo,
    super.key,
  });

  final VideoPlayerController controller;
  final VoidCallback? onHover;
  final Future<void> Function()? onResetVideo;

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
  void listener() => setState(() {
        ref.read(videoPlayerStateProvider.notifier).currPosition =
            video.position;
      });

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
    return Listener(
      onPointerDown: (_) => widget.onHover?.call(),
      onPointerHover: (_) => widget.onHover?.call(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          if (!isLive)
            Row(
              children: [
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        right: BorderSide(
                          color: Color.fromARGB(255, 192, 192, 192),
                        ),
                      ),
                    ),
                    child: Material(
                      color: Colors.transparent,
                      child: Stack(
                        children: [
                          // required only for network
                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              overlayShape: const SmallOverlayShape(),
                              trackShape: CustomTrackShape(),
                              thumbShape: SliderComponentShape.noThumb,
                              disabledActiveTrackColor:
                                  const Color.fromARGB(255, 192, 192, 192),
                              disabledInactiveTrackColor:
                                  const Color.fromARGB(255, 224, 224, 224),
                            ),
                            child: Slider(
                              max: durationToDouble(video.duration),
                              value: durationToDouble(bufferedPosition),
                              onChanged: null,
                            ),
                          ),

                          SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              overlayShape: const SmallOverlayShape(),
                              trackHeight: 2,
                              trackShape: CustomTrackShape(),
                              thumbShape: const RoundSliderThumbShape(
                                enabledThumbRadius: 6,
                                pressedElevation: 2,
                              ),
                              activeTrackColor:
                                  const Color.fromARGB(255, 64, 64, 64),
                              inactiveTrackColor:
                                  const Color.fromARGB(0, 0, 0, 0),
                            ),
                            child: Slider(
                              max: durationToDouble(video.duration),
                              value:
                                  seekValue ?? durationToDouble(video.position),
                              onChanged: (double value) =>
                                  setState(() => seekValue = value),
                              onChangeEnd: (double value) {
                                setState(() => seekValue = null);
                                widget.controller
                                    .seekTo(doubleToDuration(value));
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: Text(
                    timestamp,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),
              ],
            )
          else ...[
            if (!video.isCompleted) ...[
              const Padding(
                padding: EdgeInsets.all(2),
                child: Text(
                  'The video is still buffering on the server. '
                  'Playback may experience some interruptions.',
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
              const VideoRotation(),
            ],
          ),
        ],
      ),
    );
  }

  void onPlayPause() {
    if (widget.controller.value.isCompleted) {
      final isLive = durationToDouble(video.duration) > 10 * 60 * 60;
      if (isLive) {
        if (widget.onResetVideo != null) {
          widget.onResetVideo!().then((val) => widget.controller.play());
        } else {
          widget.controller.play();
        }
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

class VideoRotation extends ConsumerWidget {
  const VideoRotation({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final playState =
        ref.watch(videoPlayerStateProvider.select((e) => e.playState));

    if (playState == null) return const SizedBox.shrink();

    final rotation = playState.rotationInDegrees;
    final leftRotation = rotation - 90;
    final rightRotation = rotation + 90;

    void setRotation(int value) {
      ref.read(videoPlayerStateProvider.notifier).rotationInDegrees =
          (value + 360) % 360;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        children: [
          _buildIcon(
            icon: Icons.rotate_90_degrees_ccw_outlined,
            onTap: () => setRotation(leftRotation),
          ),
          const SizedBox(width: 8),
          _buildIcon(
            icon: Icons.rotate_90_degrees_cw_outlined,
            onTap: () => setRotation(rightRotation),
          ),
        ],
      ),
    );
  }

  Widget _buildIcon({required IconData icon, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Icon(icon, size: 20),
    );
  }
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  @override
  Rect getPreferredRect({
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    Offset offset = Offset.zero,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final trackHeight = sliderTheme.trackHeight ?? 4;
    final trackLeft = offset.dx + 12; // horizontal padding
    final trackTop = offset.dy + (parentBox.size.height - trackHeight) / 2;
    final trackWidth = parentBox.size.width - 24; // horizontal padding * 2
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}

class SmallOverlayShape extends SliderComponentShape {
  const SmallOverlayShape({this.size = 12});
  final double size;

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.square(size);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final paint = Paint()
      ..color = sliderTheme.overlayColor?.withValues(alpha: 255 * 0.2) ??
          Colors.grey.withValues(alpha: 255 * 0.2);
    context.canvas.drawCircle(center, size / 2, paint);
  }
}
 */
