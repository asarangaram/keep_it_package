import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
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
              parentIdentifier: parentIdentifier,
              actionControl:
                  (media.type == CLMediaType.video && !VideoEditor.isSupported)
                      ? actionControl.copyWith(allowEdit: false)
                      : actionControl,
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
          parentIdentifier: parentIdentifier,
          initialMediaIndex: initialMediaIndex,
        );
      },
    );
  }
}
