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
    required this.actionControl,
    super.key,
  });
  final int? collectionId;
  final int id;
  final String parentIdentifier;
  final ActionControl actionControl;

  @override
  Widget build(BuildContext context) {
    return FullscreenLayout(
      useSafeArea: false,
      child: StoreManager(
        builder: ({required storeAction}) {
          if (collectionId == null) {
            return GetMedia(
              id: id,
              buildOnData: (media) {
                if (media == null) {
                  return const EmptyState();
                }

                return CLPopScreen.onSwipe(
                  child: MediaViewService(
                    media: media,
                    storeAction: storeAction,
                    getPreview: (media) => Preview(media: media),
                    parentIdentifier: parentIdentifier,
                    actionControl: actionControl,
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
          }
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

              return MediaViewService.pageView(
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
              );
            },
          );
        },
      ),
    );
  }
}
