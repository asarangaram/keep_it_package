import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../widgets/empty_state.dart';
import '../widgets/preview.dart';

class MediaViewPage extends ConsumerWidget {
  const MediaViewPage({
    required this.id,
    required this.parentIdentifier,
    super.key,
  });

  final int id;
  final String parentIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FullscreenLayout(
      child: MediaHandlerWidget(
        builder: ({required action}) {
          return GetMedia(
            id: id,
            buildOnData: (media) {
              if (media == null) {
                return const EmptyState();
              }

              return CLPopScreen.onSwipe(
                child: MediaViewService(
                  media: media,
                  getPreview: (media) => Preview(media: media),
                  parentIdentifier: parentIdentifier,
                  actionControl: ActionControl.editOnly(),
                  buildNotes: (media) {
                    return NotesService(
                      media: media,
                      onUpsertNote: action.onUpsertNote,
                      onDeleteNote: action.onDeleteNote,
                      onCreateNewFile: action.createTempFile,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
