import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart'
    show ViewerEntityMixin, CLMedia, GalleryGroupCLEntity;

import '../../db_service/builders/w3_get_collection.dart';

import '../models/labeled_entity_groups.dart';
import '../providers/media_grouper.dart';
import 'get_sorted_entities.dart';

class GetGroupedMedia extends ConsumerWidget {
  const GetGroupedMedia({
    required this.viewIdentifier,
    required this.builder,
    required this.incoming,
    required this.columns,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.viewableAsCollection,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final int columns;
  final List<ViewerEntityMixin> incoming;

  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final Widget Function(
    List<LabelledEntityGroups> galleryMap, {
    required ViewerEntityMixin? Function(ViewerEntityMixin entity)? onGetParent,
    required List<ViewerEntityMixin>? Function(ViewerEntityMixin entity)?
        onGetChildren,
  }) builder;
  final bool viewableAsCollection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    incoming.sort(
      (a, b) => ((a as CLMedia).label?.toLowerCase() ?? '')
          .compareTo((b as CLMedia).label?.toLowerCase() ?? ''),
    );
    final ids = incoming
        .map((e) => (e as CLMedia).parentId)
        .where((e) => e != null)
        .map((e) => e!)
        .toSet()
        .toList();

    return GetCollectionsByIdList(
      ids: ids,
      loadingBuilder: loadingBuilder,
      errorBuilder: errorBuilder,
      builder: (collections) {
        return GetSortedEntity(
          entities: collections,
          builder: (sortedCollections) {
            final result = <LabelledEntityGroups>[];

            if (viewableAsCollection) {
              result.add(
                LabelledEntityGroups(
                  name: 'Collections',
                  galleryGroups: ref.watch(
                    groupedMediaProvider(
                      MapEntry(
                        TabIdentifier(
                          view: viewIdentifier,
                          tabId: 'Collection',
                        ),
                        sortedCollections,
                      ),
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
                    MapEntry(
                      TabIdentifier(view: viewIdentifier, tabId: 'Media'),
                      incoming,
                    ),
                  ),
                ),
              ),
            );

            return builder(
              result,
              onGetParent: (entity) => switch (entity) {
                CLMedia _ =>
                  collections.where((e) => e.id == entity.parentId).first,
                _ => null
              },
              onGetChildren: (entity) => switch (entity) {
                CLMedia _ => incoming
                    .where((e) => (e as CLMedia).parentId == entity.id)
                    .toList(),
                _ => null
              },
            );
          },
        );
      },
    );
  }
}

final groupedMediaProvider = StateProvider.family<
    List<GalleryGroupCLEntity<ViewerEntityMixin>>,
    MapEntry<TabIdentifier, List<ViewerEntityMixin>>>((ref, mapEntry) {
  final groupBy = ref.watch(groupMethodProvider(mapEntry.key.tabId));

  return groupBy.getGrouped(mapEntry.value);
});
