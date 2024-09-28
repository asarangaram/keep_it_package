import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'get_db_reader.dart';
import 'w3_get_from_store.dart';

class GetMedia extends ConsumerWidget {
  const GetMedia({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.id,
    super.key,
  });
  final Widget Function(CLMedia? media) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetDBReader(
      builder: (dbReader) {
        final q = dbReader.getQuery(DBQueries.mediaById, parameters: [id])
            as StoreQuery<CLMedia>;

        return GetFromStore<CLMedia>(
          query: q,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          builder: (data) {
            final media = data.where((e) => e.id == id).firstOrNull;

            return builder(media);
          },
        );
      },
    );
  }
}

class GetMediaByCollectionId extends ConsumerWidget {
  const GetMediaByCollectionId({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    this.collectionId,
    super.key,
  });
  final Widget Function(CLMedias items) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;
  final int? collectionId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qid = (collectionId == null)
        ? DBQueries.mediaAll
        : DBQueries.mediaByCollectionId;

    return GetDBReader(
      builder: (dbReader) {
        final q = dbReader.getQuery(
          qid,
          parameters: (collectionId == null) ? [] : [collectionId],
        ) as StoreQuery<CLMedia>;
        return GetFromStore<CLMedia>(
          query: q,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          builder: (media) {
            media.sort((a, b) {
              final aDate = a.originalDate ?? a.createdDate;
              final bDate = b.originalDate ?? b.createdDate;

              if (aDate != null && bDate != null) {
                return bDate.compareTo(aDate);
              }
              return 0;
            });
            return builder(CLMedias(media));
          },
        );
      },
    );
  }
}

class GetMediaMultipleByIds extends ConsumerWidget {
  const GetMediaMultipleByIds({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.idList,
    super.key,
  });
  final Widget Function(CLMedias items) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;
  final List<int> idList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const qid = DBQueries.mediaByIdList;

    return GetDBReader(
      builder: (dbReader) {
        final q = dbReader.getQuery(qid, parameters: ['(${idList.join(', ')})'])
            as StoreQuery<CLMedia>;

        return GetFromStore<CLMedia>(
          query: q,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          builder: (media) {
            media.sort((a, b) {
              final aDate = a.originalDate ?? a.createdDate;
              final bDate = b.originalDate ?? b.createdDate;

              if (aDate != null && bDate != null) {
                return bDate.compareTo(aDate);
              }
              return 0;
            });
            return builder(CLMedias(media));
          },
        );
      },
    );
  }
}

class GetPinnedMedia extends ConsumerWidget {
  const GetPinnedMedia({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final Widget Function(CLMedias items) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const qid = DBQueries.mediaPinned;

    return GetDBReader(
      builder: (dbReader) {
        final q = dbReader.getQuery(qid, parameters: []) as StoreQuery<CLMedia>;
        return GetFromStore<CLMedia>(
          query: q,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          builder: (media) {
            media.sort((a, b) {
              final aDate = a.originalDate ?? a.createdDate;
              final bDate = b.originalDate ?? b.createdDate;

              if (aDate != null && bDate != null) {
                return bDate.compareTo(aDate);
              }
              return 0;
            });
            return builder(CLMedias(media));
          },
        );
      },
    );
  }
}

class GetStaleMedia extends ConsumerWidget {
  const GetStaleMedia({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final Widget Function(CLMedias items) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const qid = DBQueries.mediaStaled;

    return GetDBReader(
      builder: (dbReader) {
        final q = dbReader.getQuery(qid, parameters: []) as StoreQuery<CLMedia>;
        return GetFromStore<CLMedia>(
          query: q,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          builder: (media) {
            media.sort((a, b) {
              final aDate = a.originalDate ?? a.createdDate;
              final bDate = b.originalDate ?? b.createdDate;

              if (aDate != null && bDate != null) {
                return bDate.compareTo(aDate);
              }
              return 0;
            });
            return builder(CLMedias(media));
          },
        );
      },
    );
  }
}

class GetDeletedMedia extends ConsumerWidget {
  const GetDeletedMedia({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final Widget Function(CLMedias items) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const qid = DBQueries.mediaDeleted;

    return GetDBReader(
      builder: (dbReader) {
        final q = dbReader.getQuery(qid, parameters: []) as StoreQuery<CLMedia>;
        return GetFromStore<CLMedia>(
          query: q,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          builder: (media) {
            media.sort((a, b) {
              final aDate = a.originalDate ?? a.createdDate;
              final bDate = b.originalDate ?? b.createdDate;

              if (aDate != null && bDate != null) {
                return bDate.compareTo(aDate);
              }
              return 0;
            });
            return builder(CLMedias(media));
          },
        );
      },
    );
  }
}