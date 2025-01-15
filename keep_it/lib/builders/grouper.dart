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

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    final method = ref.watch(groupMethodProvider);
    if (collectionId == null) {
      CollectionGrouper(
        columns: columns,
        incoming: incoming,
        builder: builder,
        errorBuilder: errorBuilder,
        loadingBuilder: loadingBuilder,
      );
    }

    return switch (method) {
      GroupTypes.none => builder(incoming.group(columns)),
      GroupTypes.byOriginalDate => builder(incoming.groupByTime(columns)),
    };
  }
}

class CollectionGrouper extends ConsumerWidget {
  const CollectionGrouper({
    required this.columns,
    required this.incoming,
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final int columns;
  final List<CLEntity> incoming;
  final Widget Function(List<GalleryGroupCLEntity<CLEntity>> galleryMap)
      builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final method = ref.watch(groupMethodProvider);
    final canSync =
        ref.watch(serverProvider.select((server) => server.canSync));

    final ids = incoming
        .map((e) => (e as CLMedia).collectionId)
        .where((e) => e != null)
        .map((e) => e!)
        .toSet()
        .toList();
    return GetCollectionsByIdList(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      ids: ids,
      builder: (collections) {
        final List<Collection> visibleCollections;
        if (!canSync) {
          visibleCollections = collections
              .where(
                (c) => !c.hasServerUID || (c.hasServerUID && c.haveItOffline),
              )
              .toList();
        } else {
          visibleCollections = collections;
        }
        return switch (method) {
          GroupTypes.none => builder(visibleCollections.group(columns)),
          GroupTypes.byOriginalDate =>
            builder(visibleCollections.groupByTime(columns)),
        };
      },
    );
  }
}
