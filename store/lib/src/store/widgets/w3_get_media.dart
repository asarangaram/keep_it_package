import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/m3_db_queries.dart';
import '../models/m3_db_query.dart';
import 'w3_get_from_store.dart';

class GetMedia extends ConsumerWidget {
  const GetMedia({
    required this.buildOnData,
    required this.id,
    super.key,
  });
  final Widget Function(CLMedia media) buildOnData;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetFromStore<CLMedia>(
      query: (DBQueries.mediaById.sql.copyWith(parameters: [id]))
          as DBQuery<CLMedia>,
      builder: (data) {
        final media = data.where((e) => e.id == id).firstOrNull;
        if (media != null) {
          return buildOnData(media);
        }
        throw Exception('Media not found');
      },
    );
  }
}

class GetMediaByTagId extends ConsumerWidget {
  const GetMediaByTagId({
    required this.buildOnData,
    this.tagID,
    super.key,
  });
  final Widget Function(List<CLMedia> items) buildOnData;

  final int? tagID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qid = (tagID == null) ? DBQueries.mediaAll : DBQueries.mediaByTagId;

    return GetFromStore<CLMedia>(
      query: (qid.sql as DBQuery<CLMedia>).copyWith(
        parameters: (tagID == null) ? [] : [tagID],
      ),
      builder: buildOnData,
    );
  }
}

class GetMediaByCollectionId extends ConsumerWidget {
  const GetMediaByCollectionId({
    required this.buildOnData,
    this.collectionId,
    super.key,
  });
  final Widget Function(List<CLMedia> items) buildOnData;
  final int? collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qid = (collectionId == null)
        ? DBQueries.mediaAll
        : DBQueries.mediaByCollectionId;

    return GetFromStore<CLMedia>(
      query: (qid.sql as DBQuery<CLMedia>).copyWith(
        parameters: (collectionId == null) ? [] : [collectionId],
      ),
      builder: buildOnData,
    );
  }
}
