import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../online_service/providers/server.dart';
import 'get_db_reader.dart';
import 'w3_get_from_store.dart';

class GetCollection extends ConsumerWidget {
  const GetCollection({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    this.id,
    super.key,
  });
  final Widget Function(Collection? collections) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;
  final int? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (id == null) {
      return builder(null);
    }
    return GetDBReader(
      builder: (dbReader) {
        final q = dbReader.getQuery(DBQueries.collectionById, parameters: [id])
            as StoreQuery<Collection>;
        return GetFromStore<Collection>(
          query: q,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          builder: (data) {
            final collection = data.where((e) => e.id == id).firstOrNull;
            return builder(collection);
          },
        );
      },
    );
  }
}

class GetShowableCollectionMultiple extends ConsumerWidget {
  const GetShowableCollectionMultiple({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
    this.queries = DBQueries.collectionsVisibleNotDeleted,
  });
  final Widget Function(
    Collections collections,
    List<GalleryGroup<Collection>> galleryGroups, {
    required bool isAllAvailable,
  }) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;
  final DBQueries queries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSync =
        ref.watch(serverProvider.select((server) => server.canSync));

    return GetCollectionMultiple(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      query: DBQueries.collectionsVisibleNotDeleted,
      builder: (collections) {
        final Collections visibleCollections;
        if (!canSync) {
          visibleCollections = Collections(
            collections.entries
                .where(
                  (c) => !c.hasServerUID || (c.hasServerUID && c.haveItOffline),
                )
                .toList(),
          );
        } else {
          visibleCollections = collections;
        }

        final galleryGroups = <GalleryGroup<Collection>>[];

        for (final rows in visibleCollections.entries.convertTo2D(3)) {
          galleryGroups.add(
            GalleryGroup(
              rows,
              label: null,
              groupIdentifier: 'Collections',
              chunkIdentifier: 'Collections',
            ),
          );
        }
        return builder(
          collections,
          galleryGroups,
          isAllAvailable:
              visibleCollections.entries.length == collections.entries.length,
        );
      },
    );
  }
}

class GetCollectionMultiple extends ConsumerWidget {
  const GetCollectionMultiple({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.query,
    super.key,
  });
  final Widget Function(Collections collections) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;
  final DBQueries query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetDBReader(
      builder: (dbReader) {
        final q =
            dbReader.getQuery(query, parameters: []) as StoreQuery<Collection>;

        return GetFromStore<Collection>(
          query: q,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          builder: (list) => builder(Collections(list)),
        );
      },
    );
  }
}
