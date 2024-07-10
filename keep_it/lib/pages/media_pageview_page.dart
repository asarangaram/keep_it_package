import 'package:app_loader/app_loader.dart';
import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:keep_it/widgets/preview.dart';
import 'package:store/store.dart';

import '../widgets/empty_state.dart';
import '../widgets/store_manager.dart';

class MediaPageViewPage extends StatelessWidget {
  const MediaPageViewPage({
    required this.id,
    required this.collectionId,
    required this.parentIdentifier,
    super.key,
  });
  final int collectionId;
  final int id;
  final String parentIdentifier;

  @override
  Widget build(BuildContext context) {
    return StoreManager(
      builder: ({required storeAction}) {
        return GetMediaByCollectionId(
          collectionId: collectionId,
          buildOnData: (items) {
            if (items.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                CLPopScreen.onPop(context);
              });
              return const EmptyState(message: 'No Media');
            }
            final initialMedia = items.where((e) => e.id == id).firstOrNull;
            final initialMediaIndex =
                initialMedia == null ? 0 : items.indexOf(initialMedia);

            return FullscreenLayout(
              useSafeArea: false,
              child: MediaViewService.pageView(
                media: items,
                storeAction: storeAction,
                getPreview: (media) => Preview(media: media),
                parentIdentifier: parentIdentifier,
                initialMediaIndex: initialMediaIndex,
                buildNotes: (media) {
                  return GetNotesByMediaId(
                    mediaId: media.id!,
                    buildOnData: (notes) {
                      return NotesService(
                        media: media,
                        notes: notes,
                        onUpsertNote: storeAction.onUpsertNote,
                        onDeleteNote: storeAction.onDeleteNote,
                        onCreateNewFile: storeAction.createTempFile,
                      );
                    },
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
