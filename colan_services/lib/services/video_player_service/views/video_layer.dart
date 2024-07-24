import 'package:colan_services/services/video_player_service/builders/timestamp_builder.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

import '../builders/audio_control_builder.dart';
import '../providers/show_controls.dart';

class VideoLayer extends ConsumerWidget {
  const VideoLayer({
    required this.controller,
    this.inplaceControl = false,
    super.key,
  });
  final VideoPlayerController controller;
  final bool inplaceControl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GestureDetector(
      onDoubleTap: () {
        if (controller.value.isPlaying) {
          ref
              .read(showControlsProvider.notifier)
              .briefHover(timeout: const Duration(seconds: 5));
          controller.pause();
        } else {
          ref
              .read(showControlsProvider.notifier)
              .briefHover(timeout: const Duration(seconds: 5));
          controller.play();
        }
      },
      onTap: () {
        if (controller.value.isPlaying) {
          ref
              .read(showControlsProvider.notifier)
              .briefHover(timeout: const Duration(seconds: 5));
          if (inplaceControl) {
            controller.pause();
          }
        } else {
          ref
              .read(showControlsProvider.notifier)
              .briefHover(timeout: const Duration(seconds: 5));
          controller.play();
        }
      },
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
                              return CLIcon.standard(
                                volume == 0
                                    ? Icons.volume_off
                                    : Icons.volume_up,
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
                              return CLText.standard(
                                '${currentPosition.timestamp} / ${totalDuration.timestamp}',
                                color: Colors.white,
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
