import 'dart:math';

import 'package:cl_media_viewers_flutter/cl_media_viewers_flutter.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:video_player/video_player.dart';

extension ExtDuration on Duration {
  String get timestamp {
    final hh = inHours > 0 ? "${inHours.toString().padLeft(2, '0')}:" : '';
    return '$hh'
        "${inMinutes.toString().padLeft(2, '0')}:"
        "${(inSeconds % 60).toString().padLeft(2, '0')}";
  }
}

class PlayTimeSlider extends ConsumerWidget {
  const PlayTimeSlider({required this.uri, super.key});
  final Uri uri;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetUniversalVideoControls(
      builder: (universalvideoControls) {
        return GetUriPlayStatus(
          uri: uri,
          builder: (uriPlayController, videoplayerStatus) {
            if (videoplayerStatus == null || uriPlayController == null) {
              return const SizedBox.shrink();
            }
            final bufferedPosition = min(
              videoplayerStatus.buffered.isEmpty
                  ? 0.0
                  : videoplayerStatus.buffered.last.end.inSeconds.toDouble(),
              videoplayerStatus.duration.inSeconds.toDouble(),
            );

            return Row(
              children: [
                Flexible(
                  flex: 3,
                  child: Material(
                    color: Colors.transparent,
                    child: Stack(
                      children: [
                        // required only for network
                        SliderTheme(
                          data: SliderTheme.of(context).copyWith(
                            overlayShape: const SmallOverlayShape(),
                            trackShape: CustomTrackShape(),
                            trackHeight: 2,
                            thumbShape: SliderComponentShape.noThumb,
                            disabledActiveTrackColor:
                                const Color.fromARGB(255, 192, 192, 192),
                            disabledInactiveTrackColor:
                                const Color.fromARGB(255, 224, 224, 224),
                          ),
                          child: Slider(
                            max: durationToDouble(videoplayerStatus.duration),
                            value: bufferedPosition,
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
                            thumbColor: Colors.red,
                          ),
                          child: Slider(
                            max: durationToDouble(videoplayerStatus.duration),
                            value: durationToDouble(videoplayerStatus.position),
                            onChanged: (double value) {},
                            /* seekValue ??
                            onChanged: (double value) =>
                                setState(() => seekValue = value),
                            onChangeEnd: (double value) {
                              setState(() => seekValue = null);
                              widget.controller.seekTo(doubleToDuration(value));
                            }, */
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Flexible(
                  child: FittedBox(
                    child: ShowThumbnailCore(
                      videoplayerStatus: videoplayerStatus,
                    ),
                  ),
                ),
              ],
            );
          },
        );
      },
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

class ShowThumbnailCore extends ConsumerWidget {
  const ShowThumbnailCore({required this.videoplayerStatus, super.key});
  final VideoPlayerValue videoplayerStatus;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    String timeStamp(double? seekValue) {
      final isLive =
          durationToDouble(videoplayerStatus.duration) > 10 * 60 * 60;
      final currentPosition = seekValue == null
          ? videoplayerStatus.position
          : doubleToDuration(seekValue);

      if (isLive) {
        if (videoplayerStatus.isCompleted) {
          return '__ / __';
        }
        return '${currentPosition.timestamp} / __';
      } else {
        return '${currentPosition.timestamp} / ${videoplayerStatus.duration.timestamp}';
      }
    }

    return ShadButton.ghost(
      enabled: false,
      child: Text(
        timeStamp(null),
      ),
    );
  }
}
