import 'dart:collection';

import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart' show CLEntity, CLMedia, GalleryGroupCLEntity;

import '../providers/media_grouper.dart';

class GetGroupedMedia extends ConsumerWidget {
  const GetGroupedMedia({
    required this.parentIdentifier,
    required this.builder,
    required this.incoming,
    required this.columns,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final String parentIdentifier;
  final int columns;
  final List<CLEntity> incoming;

  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final Widget Function(
    Map<String, List<GalleryGroupCLEntity<CLEntity>>> galleryMap,
  ) builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = incoming
        .map((e) => (e as CLMedia).collectionId)
        .where((e) => e != null)
        .map((e) => e!)
        .toSet()
        .toList();

    return GetCollectionsByIdList(
      ids: ids,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      builder: (collections) {
        final result = LinkedHashMap.of({
          if (collections.length > 1)
            'Collections': ref.watch(
              groupedMediaProvider(
                MapEntry('$parentIdentifier/Collection', collections),
              ),
            ),
          'Media': ref.watch(
            groupedMediaProvider(
              MapEntry('$parentIdentifier/Media', incoming),
            ),
          ),
        });

        return builder(result);
      },
    );
  }
}

final groupedMediaProvider = StateProvider.family<
    List<GalleryGroupCLEntity<CLEntity>>,
    MapEntry<String, List<CLEntity>>>((ref, mapEntry) {
  final groupBy = ref.watch(groupMethodProvider(mapEntry.key));

  return groupBy.getGrouped(mapEntry.value);
});
