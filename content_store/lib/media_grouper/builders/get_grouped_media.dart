import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart'
    show CLEntity, CLMedia, Collection, GalleryGroupCLEntity;

import '../../db_service/builders/w3_get_collection.dart';

import '../models/labeled_entity_groups.dart';
import '../providers/media_grouper.dart';

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
  final List<CLEntity> incoming;

  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final Widget Function(
    List<LabelledEntityGroups> galleryMap, {
    required CLEntity? Function(CLEntity entity)? onGetParent,
    required List<CLEntity>? Function(CLEntity entity)? onGetChildren,
  }) builder;
  final bool viewableAsCollection;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    incoming.sort(
      (a, b) => (a as CLMedia)
          .name
          .toLowerCase()
          .compareTo((b as CLMedia).name.toLowerCase()),
    );
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
        collections.sort(
          (a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()),
        );
        if (collections.length > 1 && viewableAsCollection) {
          result.add(
            LabelledEntityGroups(
              name: 'Collections',
              galleryGroups: ref.watch(
                groupedMediaProvider(
                  MapEntry(
                    TabIdentifier(view: viewIdentifier, tabId: 'Collection'),
                    collections,
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
              collections.where((e) => e.id == entity.collectionId).first,
            _ => null
          },
          onGetChildren: (entity) => switch (entity) {
            Collection _ => incoming
                .where((e) => (e as CLMedia).collectionId == entity.id)
                .toList(),
            _ => null
          },
        );
      },
    );
  }
}

final groupedMediaProvider = StateProvider.family<
    List<GalleryGroupCLEntity<CLEntity>>,
    MapEntry<TabIdentifier, List<CLEntity>>>((ref, mapEntry) {
  final groupBy = ref.watch(groupMethodProvider(mapEntry.key.tabId));

  return groupBy.getGrouped(mapEntry.value);
});
