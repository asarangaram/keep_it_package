import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'w3_get_from_store.dart';

class GetCollection extends ConsumerWidget {
  const GetCollection({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.serverIdentity,
    this.id,
    super.key,
  });
  final Widget Function(StoreEntity? collections) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final String serverIdentity;
  final int? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (id == null) {
      return builder(null);
    }
    final q = EntityQuery(serverIdentity, {'id': id, 'isCollection': 1});
    return GetFromStore(
      query: q,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: (data) {
        final collection = data.where((e) => e.id == id).firstOrNull;
        return builder(collection);
      },
    );
  }
}

class GetCollectionsByIdList extends ConsumerWidget {
  const GetCollectionsByIdList({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.ids,
    required this.serverIdentity,
    super.key,
  });
  final Widget Function(List<StoreEntity> collections) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final String serverIdentity;
  final List<int> ids;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ids.isEmpty) {
      return builder([]);
    }
    final q = EntityQuery(serverIdentity, {'id': ids, 'isCollection': 1});
    return GetFromStore(
      query: q,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: builder,
    );
  }
}

class GetAllCollections extends ConsumerWidget {
  const GetAllCollections({
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
    final q = EntityQuery(serverIdentity, const {'isCollection': 1});

    return GetFromStore(
      query: q,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: builder,
    );
  }
}

class GetRootCollections extends ConsumerWidget {
  const GetRootCollections({
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
    final q = EntityQuery(
      serverIdentity,
      const {'isCollection': 1, 'parentId': null},
    );

    return GetFromStore(
      query: q,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: builder,
    );
  }
}

class GetAllVisibleCollection extends ConsumerWidget {
  const GetAllVisibleCollection({
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
    final q = EntityQuery(
      serverIdentity,
      const {'isCollection': 1, 'isDeleted': false, 'isHidden': false},
    );

    return GetFromStore(
      query: q,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: builder,
    );
  }
}
