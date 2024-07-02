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
              .briefHover(timeout: const Duration(seconds: 3));
          controller.pause();
        } else {
          ref
              .read(showControlsProvider.notifier)
              .briefHover(timeout: const Duration(seconds: 1));
          controller.play();
        }
      },
      onTap: () {
        if (controller.value.isPlaying) {
          ref
              .read(showControlsProvider.notifier)
              .briefHover(timeout: const Duration(seconds: 3));
          if (inplaceControl) {
            controller.pause();
          }
        } else {
          ref
              .read(showControlsProvider.notifier)
              .briefHover(timeout: const Duration(seconds: 1));
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
                  left: 8,
                  child: AudioControlBuilder(
                    controller: controller,
                    builder: (volume) {
                      return CLIcon.large(
                        volume == 0 ? Icons.volume_off : Icons.volume_up,
                        color: Colors.black12.withAlpha(100),
                      );
                    },
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: TimeStampBuilder(
                    controller: controller,
                    builder: ({
                      required currentPosition,
                      required totalDuration,
                    }) {
                      return Container(
                        decoration:
                            BoxDecoration(color: Colors.white.withAlpha(100)),
                        child: Text(
                          '${currentPosition.timestamp} / ${totalDuration.timestamp}',
                        ),
                      );
                    },
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
