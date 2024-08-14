import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'get_store.dart';
import 'w3_get_from_store.dart';

class GetCollection extends ConsumerWidget {
  const GetCollection({
    required this.buildOnData,
    this.id,
    super.key,
  });
  final Widget Function(Collection? collections) buildOnData;
  final int? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (id == null) {
      return buildOnData(null);
    }
    return GetStore(
      builder: (store) {
        final q = store.getQuery(DBQueries.collectionById, parameters: [id])
            as StoreQuery<Collection>;
        return GetFromStore<Collection>(
          query: q,
          builder: (data) {
            final collection = data.where((e) => e.id == id).firstOrNull;
            return buildOnData(collection);
          },
        );
      },
    );
  }
}

class GetCollectionMultiple extends ConsumerWidget {
  const GetCollectionMultiple({
    required this.buildOnData,
    super.key,
    this.excludeEmpty = false,
  });
  final Widget Function(List<Collection> collections) buildOnData;
  final bool excludeEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qid = excludeEmpty
        ? DBQueries.collectionsExcludeEmpty
        : DBQueries.collectionsAll;

    return GetStore(
      builder: (store) {
        final q = store.getQuery(qid, parameters: []) as StoreQuery<Collection>;

        return GetFromStore<Collection>(
          query: q,
          builder: buildOnData,
        );
      },
    );
  }
}
