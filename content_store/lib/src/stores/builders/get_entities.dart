import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/store_query_result.dart';

class GetEntity extends ConsumerWidget {
  const GetEntity({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.storeIdentity,
    this.id,
    super.key,
    this.label, // Searches only collection
    this.md5, // Searches only media
  });
  final Widget Function(StoreEntity? item) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final String storeIdentity;
  final int? id;
  final int? label;
  final int? md5;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (storeIdentity != 'local') {
      throw Exception('Unknown store!');
    }
    if ([id, md5, label].every((e) => e == null)) {
      return builder(null);
    }
    final EntityQuery query;
    try {
      if ([id, md5, label].where((x) => x != null).length != 1) {
        throw Exception(
          'Incorrect usage. Use one, only one of id, md5 or label',
        );
      }
      query = EntityQuery(
        storeIdentity,
        {
          if (id != null)
            'id': id
          else if (md5 != null) ...{
            'isCollection': 0,
            'md5': md5,
          } else if (label != null) ...{
            'isCollection': 1,
            'label': label,
          },
        },
      );
    } catch (e, st) {
      return errorBuilder(e, st);
    }
    final dataAsync = ref.watch(entitiesProvider(query));
    return dataAsync.when(
      error: errorBuilder,
      loading: loadingBuilder,
      data: (entities) {
        final entity = entities.where((e) => e.id == id).firstOrNull;
        return builder(entity);
      },
    );
  }
}

class GetEntities extends ConsumerWidget {
  const GetEntities({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.storeIdentity,
    this.parentId, // parentID = 0 ignores parentId, null is a valid parentId
    this.isCollection, // isCollection = null ignores isCollection
    super.key,
    this.isHidden = false, // isHidden = null ignores isHidden
    this.isDeleted = false, // isDeleted = null ignores isDeleted
    this.hasPin,
  });
  final Widget Function(List<StoreEntity> items) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final String storeIdentity;
  final int? parentId;
  final bool? isCollection;
  final bool? isHidden;
  final bool? isDeleted;
  final bool? hasPin;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (storeIdentity != 'local') {
      throw Exception('Unknown store!');
    }
    final query = EntityQuery(
      storeIdentity,
      {
        if (isHidden != null) 'isHidden': isHidden! ? 1 : 0,
        if (isDeleted != null) 'isDeleted': isDeleted! ? 1 : 0,
        if (parentId != 0) 'parentId': parentId,
        if (isCollection != null) 'isCollection': isCollection! ? 1 : 0,
        if (hasPin != null) 'pin': hasPin! ? NotNullValues : null,
      },
    );

    final dataAsync = ref.watch(entitiesProvider(query));
    return dataAsync.when(
      error: errorBuilder,
      loading: loadingBuilder,
      data: builder,
    );
  }
}
