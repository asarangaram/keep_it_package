import 'dart:io';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../modules/notes/notes_view.dart';

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
    return Column(
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
        if (showControl.showNotes) ...[
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Divider(
              height: 2,
              thickness: 3,
              indent: 4,
              endIndent: 4,
            ),
          ),
          SafeArea(
            top: false,
            child: NotesView(
              media: media,
              onClose: () {
                ref.read(showControlsProvider.notifier).hideNotes();
              },
            ),
          ),
        ],
      ],
    );
  }
}
