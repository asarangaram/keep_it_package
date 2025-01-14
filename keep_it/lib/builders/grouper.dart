import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../navigation/providers/active_collection.dart';

enum GroupTypes { none, byOriginalDate }

final groupMethodProvider = StateProvider<GroupTypes>((ref) {
  return GroupTypes.none;
});

class GetGroupedMedia extends ConsumerWidget {
  const GetGroupedMedia({
    required this.builder,
    required this.incoming,
    required this.columns,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final int columns;
  final List<CLEntity> incoming;

  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final Widget Function(List<GalleryGroupCLEntity<CLEntity>> galleryMap)
      builder;
  List<GalleryGroupCLEntity<CLEntity>> group(List<CLEntity> entities) {
    final galleryGroups = <GalleryGroupCLEntity<CLEntity>>[];

    for (final rows in entities.convertTo2D(columns)) {
      galleryGroups.add(
        GalleryGroupCLEntity(
          rows,
          label: null,
          groupIdentifier: 'CLEntity',
          chunkIdentifier: 'CLEntity',
        ),
      );
    }
    return galleryGroups;
  }

  List<GalleryGroupCLEntity<CLEntity>> groupByTime(List<CLEntity> entities) {
    final galleryGroups = <GalleryGroupCLEntity<CLEntity>>[];

    for (final entry in entities.filterByDate().entries) {
      if (entry.value.length > 20) {
        final groups = entry.value.convertTo2D(20);

        for (final (index, group) in groups.indexed) {
          galleryGroups.add(
            GalleryGroupCLEntity(
              group,
              label: (index == 0) ? entry.key : null,
              groupIdentifier: entry.key,
              chunkIdentifier: '${entry.key} $index',
            ),
          );
        }
      } else {
        galleryGroups.add(
          GalleryGroupCLEntity(
            entry.value,
            label: entry.key,
            groupIdentifier: entry.key,
            chunkIdentifier: entry.key,
          ),
        );
      }
    }
    return galleryGroups;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ids = incoming
        .map((e) => (e as CLMedia).collectionId)
        .where((e) => e != null)
        .map((e) => e!)
        .toSet()
        .toList();

    final collectionId = ref.watch(activeCollectionProvider);
    final method = ref.watch(groupMethodProvider);
    if (collectionId == null) {
      return GetCollectionsByIdList(
        errorBuilder: errorBuilder,
        loadingBuilder: loadingBuilder,
        ids: ids,
        builder: (collections) {
          return switch (method) {
            GroupTypes.none => builder(group(collections)),
            GroupTypes.byOriginalDate => builder(groupByTime(collections)),
          };
        },
      );
    }

    return switch (method) {
      GroupTypes.none => builder(group(incoming)),
      GroupTypes.byOriginalDate => builder(groupByTime(incoming)),
    };
  }
}
