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
      builder: (media) {
        media.sort((a, b) {
          final aDate = a.originalDate ?? a.createdDate;
          final bDate = b.originalDate ?? b.createdDate;

          if (aDate != null && bDate != null) {
            return bDate.compareTo(aDate);
          }
          return 0;
        });
        return buildOnData(media);
      },
    );
  }
}

class GetMediaMultiple extends ConsumerWidget {
  const GetMediaMultiple({
    required this.buildOnData,
    required this.idList,
    super.key,
  });
  final Widget Function(List<CLMedia> items) buildOnData;
  final List<int> idList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const qid = DBQueries.mediaByIdList;

    return GetFromStore<CLMedia>(
      query: (qid.sql as DBQuery<CLMedia>).copyWith(
        parameters: ['(${idList.join(', ')})'],
      ),
      builder: (media) {
        media.sort((a, b) {
          final aDate = a.originalDate ?? a.createdDate;
          final bDate = b.originalDate ?? b.createdDate;

          if (aDate != null && bDate != null) {
            return bDate.compareTo(aDate);
          }
          return 0;
        });
        return buildOnData(media);
      },
    );
  }
}

class GetPinnedMedia extends ConsumerWidget {
  const GetPinnedMedia({
    required this.buildOnData,
    super.key,
  });
  final Widget Function(List<CLMedia> items) buildOnData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const qid = DBQueries.mediaPinned;

    return GetFromStore<CLMedia>(
      query: qid.sql as DBQuery<CLMedia>,
      builder: (media) {
        media.sort((a, b) {
          final aDate = a.originalDate ?? a.createdDate;
          final bDate = b.originalDate ?? b.createdDate;

          if (aDate != null && bDate != null) {
            return bDate.compareTo(aDate);
          }
          return 0;
        });
        return buildOnData(media);
      },
    );
  }
}

class GetStaleMedia extends ConsumerWidget {
  const GetStaleMedia({
    required this.buildOnData,
    super.key,
  });
  final Widget Function(List<CLMedia> items) buildOnData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const qid = DBQueries.mediaStaled;

    return GetFromStore<CLMedia>(
      query: qid.sql as DBQuery<CLMedia>,
      builder: (media) {
        media.sort((a, b) {
          final aDate = a.originalDate ?? a.createdDate;
          final bDate = b.originalDate ?? b.createdDate;

          if (aDate != null && bDate != null) {
            return bDate.compareTo(aDate);
          }
          return 0;
        });
        return buildOnData(media);
      },
    );
  }
}
