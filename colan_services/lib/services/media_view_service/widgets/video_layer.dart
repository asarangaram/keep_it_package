/* import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'package:video_player/video_player.dart';

import '../builders/audio_control_builder.dart';
import '../builders/timestamp_builder.dart';

import '../models/ext_duration.dart';

class VideoInPlaceControls extends StatelessWidget {
  const VideoInPlaceControls({
    required this.controller,
    this.onDoubleTap,
    this.onTap,
    super.key,
  });
  final VideoPlayerController controller;

  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onDoubleTap: onDoubleTap,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white10..withAlpha(64),
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 8, right: 8, bottom: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AudioControlBuilder(
                controller: controller,
                builder: (volume) {
                  return Icon(
                    volume == 0
                        ? videoPlayerIcons.audioMuted
                        : videoPlayerIcons.audioUnmuted,
                    color: Colors.white,
                  );
                },
              ),
              TimeStampBuilder(
                controller: controller,
                builder: ({
                  required currentPosition,
                  required totalDuration,
                }) {
                  return Text(
                    '${currentPosition.timestamp} / ${totalDuration.timestamp}',
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                        ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  VideoPlayerValue get video => controller.value;
  String get timestamp {
    final currentPosition = video.position;
    return '${currentPosition.timestamp} / ${video.duration.timestamp}';
  }
}
 */
