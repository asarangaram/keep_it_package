import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/m3_db_queries.dart';
import '../models/m3_db_query.dart';
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
    return GetFromStore<Collection>(
      query: (DBQueries.collectionById.sql.copyWith(parameters: [id]))
          as DBQuery<Collection>,
      builder: (data) {
        final collection = data.where((e) => e.id == id).firstOrNull;
        return buildOnData(collection);
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
    final q = qid.sql as DBQuery<Collection>;
    final qWithParam = q.copyWith(parameters: []);
    return GetFromStore<Collection>(
      query: qWithParam,
      builder: buildOnData,
    );
  }
}
