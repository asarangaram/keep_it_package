import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/show_controls.dart';
import 'controls/on_toggle_audio_mute.dart';
import 'controls/on_toggle_play.dart';
import 'controls/toggle_fullscreen.dart';
import 'controls/video_progress.dart';
import 'media_background.dart';

class EntityFullScreenView extends ConsumerWidget {
  const EntityFullScreenView({
    required this.entity,
    required this.child,
    super.key,
  });
  final ViewerEntityMixin entity;
  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final uri = entity.mediaUri!;
    final showControls =
        ref.watch(showControlsProvider.select((e) => e.showControls));
    return Center(
      child: Column(
        children: [
          Flexible(
            child: Stack(
              children: [
                const MediaBackground(),
                Center(
                  child: Stack(
                    children: [
                      InkWell(
                        onHover: (onHover) => ref
                            .read(showControlsProvider.notifier)
                            .briefHover(),
                        child: child,
                      ),
                      if (showControls)
                        ...switch (entity.mediaType) {
                          CLMediaType.video => [
                              Positioned(
                                bottom: 0,
                                left: 0,
                                right: 0,
                                child: VideoProgress(uri: uri),
                              ),
                              const Positioned(
                                top: 8,
                                right: 8,
                                child: OnToggleFullScreen(),
                              ),
                              Positioned(
                                top: 8,
                                left: 8,
                                child: OnToggleAudioMute(uri: uri),
                              ),
                              Positioned(
                                top: 4,
                                right: 4,
                                left: 4,
                                bottom: 4,
                                child: Center(
                                  child: DecoratedBox(
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: CLTheme.of(context)
                                          .colors
                                          .iconBackgroundTransparent, // Color for the circular container
                                    ),
                                    child: OnTogglePlay(uri: uri),
                                  ),
                                ),
                              ),
                            ],
                          CLMediaType.collection => [const SizedBox.shrink()],
                          CLMediaType.text => [const SizedBox.shrink()],
                          CLMediaType.image => [const SizedBox.shrink()],
                          CLMediaType.audio => [const SizedBox.shrink()],
                          CLMediaType.file => [const SizedBox.shrink()],
                          CLMediaType.uri => [const SizedBox.shrink()],
                          CLMediaType.unknown => [const SizedBox.shrink()],
                        },
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
