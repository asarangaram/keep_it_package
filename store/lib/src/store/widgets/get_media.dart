import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/db_query.dart';

import 'async_widgets.dart';

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
    return BuildOnQueryMultiple<CLMedia>(
      query: (QueryId.media.sql.copyWith(parameters: [id])) as DBQuery<CLMedia>,
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

class GetMediaMultiple extends ConsumerWidget {
  const GetMediaMultiple({
    required this.buildOnData,
    this.collectionId,
    this.tagID,
    super.key,
  });
  final Widget Function(List<CLMedia> items) buildOnData;
  final int? collectionId;
  final int? tagID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (collectionId != null && tagID != null) {
      throw Exception("can't specify both collection ID and tag ID");
    }
    final qid = (collectionId == null)
        ? (tagID == null)
            ? QueryId.mediaAll
            : QueryId.mediaByTagID
        : QueryId.mediaByCollectionID;

    return BuildOnQueryMultiple<CLMedia>(
      query: (qid.sql as DBQuery<CLMedia>).copyWith(
        parameters: (collectionId == null)
            ? (tagID == null)
                ? []
                : [tagID]
            : [collectionId],
      ),
      builder: buildOnData,
    );
  }
}
