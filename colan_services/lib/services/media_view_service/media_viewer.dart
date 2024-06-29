import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../image_view_service/image_view_service.dart';
import '../notes_service/notes_service.dart';
import '../preview_service/view/preview.dart';
import '../video_player_service/providers/show_controls.dart';
import '../video_player_service/video_player.dart';

class MediaViewer extends ConsumerWidget {
  const MediaViewer({
    required this.media,
    required this.onLockPage,
    required this.autoStart,
    super.key,
  });
  final CLMedia media;
  final void Function({required bool lock})? onLockPage;
  final bool autoStart;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final showControl = ref.watch(showControlsProvider);
    return SafeArea(
      top: showControl.showNotes,
      bottom: showControl.showNotes,
      left: showControl.showNotes,
      right: showControl.showNotes,
      child: Column(
        children: [
          Expanded(
            child: switch (media.type) {
              CLMediaType.image => ImageViewService(
                  file: File(media.path),
                  onLockPage: onLockPage,
                ),
              CLMediaType.video => VideoPlayerService.player(
                  media: media,
                  alternate: PreviewService(
                    media: media,
                  ),
                  autoStart: autoStart,
                ),
              _ => throw UnimplementedError('Not yet implemented')
            },
          ),
          if (showControl.showNotes) NotesService(media: media),
        ],
      ),
    );
  }
}
