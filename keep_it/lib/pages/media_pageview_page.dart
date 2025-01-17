import 'package:colan_services/colan_services.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MediaPageViewPage extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    if (collectionId == null) {
      return GetMedia(
        id: id,
        errorBuilder: (_, __) {
          throw UnimplementedError('errorBuilder');
          // ignore: dead_code
        },
        loadingBuilder: () {
          throw UnimplementedError('loadingBuilder');
          // ignore: dead_code
        },
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
        errorBuilder: (_, __) {
          throw UnimplementedError('errorBuilder');
          // ignore: dead_code
        },
        loadingBuilder: () {
          throw UnimplementedError('loadingBuilder');
          // ignore: dead_code
        },
        builder: (items) {
          if (items.isEmpty) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              PageManager.of(context, ref).pop();
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
