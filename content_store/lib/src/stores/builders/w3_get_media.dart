/* import 'dart:developer' as dev; */

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

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
    required this.serverIdentity,
    required this.id,
    super.key,
  });
  final Widget Function(StoreEntity? media) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final String serverIdentity;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = EntityQuery(serverIdentity, {'id': id, 'isCollection': 1});
    return GetFromStore(
      query: q,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: (data) {
        final media = data.where((e) => e.id == id).firstOrNull;
        return builder(media);
      },
    );
  }
}

class GetAllMedia extends ConsumerWidget {
  const GetAllMedia({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    this.serverIdentity,
    super.key,
  });
  final Widget Function(List<StoreEntity> collections) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final String? serverIdentity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = EntityQuery(serverIdentity, const {'isCollection': 0});

    return GetFromStore(
      query: q,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: builder,
    );
  }
}

class GetMediaByCollectionId extends ConsumerWidget {
  const GetMediaByCollectionId({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.serverIdentity,
    required this.parentId,
    super.key,
  });
  final Widget Function(List<StoreEntity> items) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final String serverIdentity;
  final int parentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = EntityQuery(
      serverIdentity,
      {'isCollection': false, 'parentId': parentId},
    );

    return GetFromStore(
      query: query,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: builder,
    );
  }
}

class GetMediaMultipleByIds extends ConsumerWidget {
  const GetMediaMultipleByIds({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.ids,
    required this.serverIdentity,
    super.key,
  });
  final Widget Function(List<StoreEntity> items) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final String serverIdentity;
  final List<int> ids;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ids.isEmpty) {
      return builder([]);
    }
    final q = EntityQuery(serverIdentity, {'id': ids, 'isCollection': 0});
    return GetFromStore(
      query: q,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: builder,
    );
  }
}

class GetPinnedMedia extends ConsumerWidget {
  const GetPinnedMedia({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    this.serverIdentity,
    super.key,
  });
  final Widget Function(List<StoreEntity> items) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final String? serverIdentity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = EntityQuery(serverIdentity, const {'pin': NotNullValues});
    return GetFromStore(
      query: q,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: builder,
    );
  }
}

class GetStaleMedia extends ConsumerWidget {
  const GetStaleMedia({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    this.serverIdentity,
    super.key,
  });
  final Widget Function(List<StoreEntity> items) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final String? serverIdentity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = EntityQuery(serverIdentity, const {'isHidden': 1});
    return GetFromStore(
      query: q,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: builder,
    );
  }
}

class GetDeletedMedia extends ConsumerWidget {
  const GetDeletedMedia({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    this.serverIdentity,
    super.key,
  });
  final Widget Function(List<StoreEntity> items) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final String? serverIdentity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = EntityQuery(serverIdentity, const {'isDeleted': 1});
    return GetFromStore(
      query: q,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: builder,
    );
  }
}
