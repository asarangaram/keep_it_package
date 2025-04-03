/* import 'dart:developer' as dev; */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'get_db_reader.dart';
import 'w3_get_from_store.dart';

/* void _log(
  dynamic message, {
  int level = 0,
  Object? error,
  StackTrace? stackTrace,
  String? name,
}) {
  dev.log(
    message.toString(),
    level: level,
    error: error,
    stackTrace: stackTrace,
    name: name ?? 'Media Builder',
  );
} */

class GetMedia extends ConsumerWidget {
  const GetMedia({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.id,
    super.key,
  });
  final Widget Function(CLEntity? media) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetDBReader(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: (dbReader) {
        final q = dbReader.getQuery(DBQueries.mediaById, parameters: [id])
            as StoreQuery<CLEntity>;

        return GetFromStore<CLEntity>(
          query: q,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          builder: (data) {
            final media = data.where((e) => e.id == id).firstOrNull;
            //_log(media?.md5String, name: 'GetMedia');
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
    this.parentId,
    super.key,
  });
  final Widget Function(List<CLEntity> items) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final int? parentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final qid = (parentId == null)
        ? DBQueries.entitiesVisible
        : DBQueries.mediaByCollectionId;

    return GetDBReader(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: (dbReader) {
        final q = dbReader.getQuery(
          qid,
          parameters: (parentId == null) ? [] : [parentId],
        ) as StoreQuery<CLEntity>;
        return GetFromStore<CLEntity>(
          query: q,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          builder: builder,
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
  final Widget Function(List<CLEntity> items) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final List<int> idList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const qid = DBQueries.mediaByIdList;

    return GetDBReader(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: (dbReader) {
        final q = dbReader.getQuery(qid, parameters: ['(${idList.join(', ')})'])
            as StoreQuery<CLEntity>;

        return GetFromStore<CLEntity>(
          query: q,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          builder: builder,
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
  final Widget Function(List<CLEntity> items) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const qid = DBQueries.mediaPinned;

    return GetDBReader(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: (dbReader) {
        final q =
            dbReader.getQuery(qid, parameters: []) as StoreQuery<CLEntity>;
        return GetFromStore<CLEntity>(
          query: q,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          builder: builder,
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
  final Widget Function(List<CLEntity> items) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const qid = DBQueries.mediaStaled;

    return GetDBReader(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: (dbReader) {
        final q =
            dbReader.getQuery(qid, parameters: []) as StoreQuery<CLEntity>;
        return GetFromStore<CLEntity>(
          query: q,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          builder: builder,
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
  final Widget Function(List<CLEntity> items) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const qid = DBQueries.mediaDeleted;

    return GetDBReader(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: (dbReader) {
        final q =
            dbReader.getQuery(qid, parameters: []) as StoreQuery<CLEntity>;
        return GetFromStore<CLEntity>(
          query: q,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          builder: builder,
        );
      },
    );
  }
}
