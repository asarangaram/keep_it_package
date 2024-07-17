import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'get_store.dart';
import 'w3_get_from_store.dart';

class GetMedia extends ConsumerWidget {
  const GetMedia({
    required this.buildOnData,
    required this.id,
    super.key,
  });
  final Widget Function(CLMedia? media) buildOnData;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetStore(
      builder: (store) {
        final q = store.getQuery(DBQueries.mediaById, parameters: [id])
            as StoreQuery<CLMedia>;

        return GetFromStore<CLMedia>(
          query: q,
          builder: (data) {
            final media = data.where((e) => e.id == id).firstOrNull;

            return buildOnData(media);
          },
        );
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

    return GetStore(
      builder: (store) {
        final q = store.getQuery(
          qid,
          parameters: (collectionId == null) ? [] : [collectionId],
        ) as StoreQuery<CLMedia>;
        return GetFromStore<CLMedia>(
          query: q,
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

    return GetStore(
      builder: (store) {
        final q = store.getQuery(qid, parameters: ['(${idList.join(', ')})'])
            as StoreQuery<CLMedia>;

        return GetFromStore<CLMedia>(
          query: q,
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

    return GetStore(
      builder: (store) {
        final q = store.getQuery(qid, parameters: []) as StoreQuery<CLMedia>;
        return GetFromStore<CLMedia>(
          query: q,
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

    return GetStore(
      builder: (store) {
        final q = store.getQuery(qid, parameters: []) as StoreQuery<CLMedia>;
        return GetFromStore<CLMedia>(
          query: q,
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
      },
    );
  }
}

class GetDeletedMedia extends ConsumerWidget {
  const GetDeletedMedia({
    required this.buildOnData,
    super.key,
  });
  final Widget Function(List<CLMedia> items) buildOnData;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const qid = DBQueries.mediaDeleted;

    return GetStore(
      builder: (store) {
        final q = store.getQuery(qid, parameters: []) as StoreQuery<CLMedia>;
        return GetFromStore<CLMedia>(
          query: q,
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
      },
    );
  }
}
