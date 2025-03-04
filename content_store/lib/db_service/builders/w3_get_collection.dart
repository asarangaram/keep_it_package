import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

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
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final int? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (id == null) {
      return builder(null);
    }
    return GetDBReader(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
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

class GetCollectionsByIdList extends ConsumerWidget {
  const GetCollectionsByIdList({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.ids,
    super.key,
  });
  final Widget Function(List<Collection> collections) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final List<int> ids;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ids.isEmpty) {
      return builder([]);
    }
    return GetDBReader(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: (dbReader) {
        final q = dbReader.getQuery(
          DBQueries.collectionByIdList,
          parameters: ['(${ids.join(', ')})'],
        ) as StoreQuery<Collection>;
        return GetFromStore<Collection>(
          query: q,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          builder: builder,
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
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final DBQueries query;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetDBReader(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
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
