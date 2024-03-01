import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/m3_db_query.dart';
import '../models/m3_db_queries.dart';

import 'w3_get_from_store.dart';

class GetTag extends ConsumerWidget {
  const GetTag({
    required this.buildOnData,
    required this.id,
    super.key,
  });
  final Widget Function(Tag? tag) buildOnData;
  final int? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (id == null) {
      return buildOnData(null);
    }
    return GetFromStore<Tag>(
      query: (DBQueries.tagById.sql.copyWith(parameters: [id])) as DBQuery<Tag>,
      builder: (data) {
        final tag = data.where((e) => e.id == id).firstOrNull;
        return buildOnData(tag);
      },
    );
  }
}

class GetTagMultiple extends ConsumerWidget {
  const GetTagMultiple({
    required this.buildOnData,
    super.key,
    this.collectionId,
    this.excludeEmpty = false,
  });
  final Widget Function(List<Tag> tags) buildOnData;
  final bool excludeEmpty;
  final int? collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qid = excludeEmpty
        ? (collectionId == null)
            ? DBQueries.tagsAllExcludeEmpty
            : DBQueries.tagsByCollectionIDExcludeEmpty
        : (collectionId == null)
            ? DBQueries.tagsAll
            : DBQueries.tagsByCollectionId;

    return GetFromStore<Tag>(
      query: (qid.sql as DBQuery<Tag>)
          .copyWith(parameters: (collectionId == null) ? [] : [collectionId]),
      builder: buildOnData,
    );
  }
}
