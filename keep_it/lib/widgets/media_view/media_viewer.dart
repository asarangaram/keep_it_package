import 'dart:io';

import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:store/store.dart';

import '../../modules/notes/notes_view.dart';
import '../../modules/notes/widgets/audio_notes.dart';

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
          if (showControl.showNotes) Notes(media: media),
        ],
      ),
    );
  }
}

class Notes extends ConsumerWidget {
  const Notes({required this.media, super.key});
  final CLMedia media;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: GetNotesByMediaId(
          mediaId: media.id!,
          buildOnData: (notes) {
            final audioNotes = notes
                .where(
                  (e) {
                    return e.type == CLNoteTypes.audio;
                  },
                )
                .map((e) => e as CLAudioNote)
                .toList();

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Divider(
                  height: 2,
                  thickness: 3,
                  indent: 4,
                  endIndent: 4,
                ),
                SizedBox(
                  height: kMinInteractiveDimension,
                  child: CLButtonIcon.standard(
                    MdiIcons.chevronDown,
                    onTap: () {
                      ref.read(showControlsProvider.notifier).hideNotes();
                    },
                  ),
                ),
                SizedBox(
                  height: audioNotes.isEmpty
                      ? kMinInteractiveDimension
                      : kMinInteractiveDimension * 2,
                  child: AudioNotes(
                    media: media,
                    audioNotes: audioNotes,
                  ),
                ),
                const Divider(
                  height: 2,
                  thickness: 1,
                  indent: 4,
                  endIndent: 4,
                ),
                SizedBox(
                  height: 200,
                  child: NotesView(
                    media: media,
                    onClose: () {
                      ref.read(showControlsProvider.notifier).hideNotes();
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
