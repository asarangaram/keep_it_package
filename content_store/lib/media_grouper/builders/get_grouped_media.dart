import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart' show CLEntity, CLMedia, GalleryGroupCLEntity;

import '../../db_service/builders/w3_get_collection.dart';

import '../models/labeled_entity_groups.dart';
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
    List<LabelledEntityGroups> galleryMap,
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
        final result = <LabelledEntityGroups>[];

        if (collections.length > 1) {
          result.add(
            LabelledEntityGroups(
              name: 'Collections',
              galleryGroups: ref.watch(
                groupedMediaProvider(
                  MapEntry('$parentIdentifier/Collection', collections),
                ),
              ),
            ),
          );
        }
        result.add(
          LabelledEntityGroups(
            name: 'Media',
            galleryGroups: ref.watch(
              groupedMediaProvider(
                MapEntry('$parentIdentifier/Media', incoming),
              ),
            ),
          ),
        );

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
