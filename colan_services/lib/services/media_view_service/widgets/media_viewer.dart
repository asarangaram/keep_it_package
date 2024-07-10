import 'dart:io';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaViewerRaw extends ConsumerWidget {
  const MediaViewerRaw({
    required this.media,
    required this.onLockPage,
    required this.autoStart,
    required this.isLocked,
    required this.buildNotes,
    required this.getPreview,
    super.key,
  });
  final CLMedia media;
  final void Function({required bool lock})? onLockPage;
  final bool autoStart;
  final bool isLocked;
  final Widget Function(CLMedia media) buildNotes;
  final Widget Function(CLMedia media) getPreview;

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
                  alternate: getPreview(media),
                  autoStart: autoStart,
                  inplaceControl: showControl.showNotes,
                ),
              _ => throw UnimplementedError('Not yet implemented')
            },
          ),
          if (showControl.showNotes && !isLocked)
            GestureDetector(
              onVerticalDragEnd: (DragEndDetails details) {
                if (details.primaryVelocity == null) return;
                // pop on Swipe
                if (details.primaryVelocity! > 0) {
                  ref.read(showControlsProvider.notifier).hideNotes();
                }
              },
              child: buildNotes(media),
            ),
        ],
      ),
    );
  }
}
