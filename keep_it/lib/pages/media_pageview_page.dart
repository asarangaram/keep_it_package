import 'package:colan_services/colan_services.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';

class MediaPageViewPage extends StatelessWidget {
  const MediaPageViewPage({
    required this.id,
    required this.collectionId,
    required this.parentIdentifier,
    super.key,
  });
  final int? collectionId;
  final int id;
  final String parentIdentifier;

  @override
  Widget build(BuildContext context) {
    if (collectionId == null) {
      return GetMedia(
        id: id,
        errorBuilder: null,
        loadingBuilder: null,
        builder: (media) {
          if (media == null) {
            return const EmptyState();
          }
          return CLPopScreen.onSwipe(
            child: MediaViewService(
              media: media,
              parentIdentifier: parentIdentifier,
            ),
          );
        },
      );
    } else {
      return GetMediaByCollectionId(
        collectionId: collectionId,
        errorBuilder: null,
        loadingBuilder: null,
        builder: (items) {
          if (items.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              CLPopScreen.onPop(context);
            });
            return const EmptyState(message: 'No Media');
          }
          final initialMedia =
              items.entries.where((e) => e.id == id).firstOrNull;
          final initialMediaIndex =
              initialMedia == null ? 0 : items.entries.indexOf(initialMedia);

          return MediaViewService.pageView(
            media: items.entries,
            parentIdentifier: parentIdentifier,
            initialMediaIndex: initialMediaIndex,
          );
        },
      );
    }
  }
}
