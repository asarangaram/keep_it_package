import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:media_editors/media_editors.dart';
import 'package:store/store.dart';

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
    return GetStore(
      builder: (theStore) {
        if (collectionId == null) {
          final media = theStore.getMediaById(id);
          if (media == null) {
            return const EmptyState();
          }

          return CLPopScreen.onSwipe(
            child: MediaViewService(
              media: media,
              parentIdentifier: parentIdentifier,
              actionControl:
                  (media.type == CLMediaType.video && !VideoEditor.isSupported)
                      ? actionControl.copyWith(allowEdit: false)
                      : actionControl,
            ),
          );
        } else {
          final items = theStore.getMediaByCollectionId(collectionId);
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
            parentIdentifier: parentIdentifier,
            initialMediaIndex: initialMediaIndex,
          );
        }
      },
    );
  }
}
