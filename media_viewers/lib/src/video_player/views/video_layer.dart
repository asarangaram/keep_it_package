import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../builders/audio_control_builder.dart';
import '../builders/timestamp_builder.dart';
import '../models/cl_icons.dart';
import '../models/ext_duration.dart';

class VideoLayer extends ConsumerWidget {
  const VideoLayer({
    required this.controller,
    this.inplaceControl = false,
    this.onDoubleTap,
    this.onTap,
    super.key,
  });
  final VideoPlayerController controller;
  final bool inplaceControl;
  final VoidCallback? onTap;
  final VoidCallback? onDoubleTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onDoubleTap: onDoubleTap,
      onTap: onTap,
      child: Center(
        child: AspectRatio(
          aspectRatio: controller.value.aspectRatio,
          child: Stack(
            children: [
              Positioned.fill(
                child: Align(
                  alignment: AlignmentDirectional.bottomCenter,
                  child: VideoPlayer(controller),
                ),
              ),
              if (inplaceControl) ...[
                Positioned(
                  bottom: 8,
                  left: 0,
                  right: 0,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white10..withAlpha(64),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
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
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                    ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
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
