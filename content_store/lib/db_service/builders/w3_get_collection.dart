import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'w3_get_from_store.dart';

class GetCollection extends ConsumerWidget {
  const GetCollection({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    this.id,
    super.key,
  });
  final Widget Function(CLEntity? collections) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final int? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (id == null) {
      return builder(null);
    }
    final q =
        EntityQuery({'id': id, 'isCollection': 1}) as StoreQuery<CLEntity>;
    return GetFromStore<CLEntity>(
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
    super.key,
  });
  final Widget Function(List<CLEntity> collections) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final List<int> ids;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ids.isEmpty) {
      return builder([]);
    }
    final q =
        EntityQuery({'id': ids, 'isCollection': 1}) as StoreQuery<CLEntity>;
    return GetFromStore<CLEntity>(
      query: q,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: builder,
    );
  }
}

class GetAllCollection extends ConsumerWidget {
  const GetAllCollection({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final Widget Function(List<CLEntity> collections) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const q = EntityQuery({'isCollection': 1}) as StoreQuery<CLEntity>;

    return GetFromStore<CLEntity>(
      query: q,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: builder,
    );
  }
}

class GetRootCollection extends ConsumerWidget {
  const GetRootCollection({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final Widget Function(List<CLEntity> collections) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const q = EntityQuery({'isCollection': 1, 'parentId': null})
        as StoreQuery<CLEntity>;

    return GetFromStore<CLEntity>(
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
    super.key,
  });
  final Widget Function(List<CLEntity> collections) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const q = EntityQuery(
      {'isCollection': 1, 'isDeleted': false, 'isHidden': false},
    ) as StoreQuery<CLEntity>;

    return GetFromStore<CLEntity>(
      query: q,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      builder: builder,
    );
  }
}
