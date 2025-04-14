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
    required this.storeIdentity,
    required this.id,
    super.key,
  });
  final Widget Function(StoreEntity? media) builder;
  final Widget Function(String errorMsg) errorBuilder;
  final Widget Function() loadingBuilder;
  final String storeIdentity;
  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = EntityQuery(storeIdentity, {'id': id, 'isCollection': 1});
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
    this.storeIdentity,
    super.key,
  });
  final Widget Function(List<StoreEntity> collections) builder;
  final Widget Function(String errorMsg) errorBuilder;
  final Widget Function() loadingBuilder;
  final String? storeIdentity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = EntityQuery(storeIdentity, const {'isCollection': 0});

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
    required this.storeIdentity,
    required this.parentId,
    super.key,
  });
  final Widget Function(List<StoreEntity> items) builder;
  final Widget Function(String errorMsg) errorBuilder;
  final Widget Function() loadingBuilder;
  final String storeIdentity;
  final int parentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final query = EntityQuery(
      storeIdentity,
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
    required this.storeIdentity,
    super.key,
  });
  final Widget Function(List<StoreEntity> items) builder;
  final Widget Function(String errorMsg) errorBuilder;
  final Widget Function() loadingBuilder;
  final String storeIdentity;
  final List<int> ids;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ids.isEmpty) {
      return builder([]);
    }
    final q = EntityQuery(storeIdentity, {'id': ids, 'isCollection': 0});
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
    this.storeIdentity,
    super.key,
  });
  final Widget Function(List<StoreEntity> items) builder;
  final Widget Function(String errorMsg) errorBuilder;
  final Widget Function() loadingBuilder;
  final String? storeIdentity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = EntityQuery(storeIdentity, const {'pin': NotNullValues});
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
    this.storeIdentity,
    super.key,
  });
  final Widget Function(List<StoreEntity> items) builder;
  final Widget Function(String errorMsg) errorBuilder;
  final Widget Function() loadingBuilder;
  final String? storeIdentity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = EntityQuery(storeIdentity, const {'isHidden': 1});
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
    this.storeIdentity,
    super.key,
  });
  final Widget Function(List<StoreEntity> items) builder;
  final Widget Function(String errorMsg) errorBuilder;
  final Widget Function() loadingBuilder;
  final String? storeIdentity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final q = EntityQuery(storeIdentity, const {'isDeleted': 1});
    return GetFromStore(
      query: q,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: builder,
    );
  }
}
