import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../providers/active_collection.dart';

class GetAvailableMediaByCollectionId extends ConsumerWidget {
  const GetAvailableMediaByCollectionId({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.storeIdentity,
    super.key,
    this.parentId,
  });
  final int? parentId;
  final Widget Function(List<StoreEntity> items) builder;
  final Widget Function(String errorMsg) errorBuilder;
  final Widget Function() loadingBuilder;
  final String storeIdentity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (parentId == null) {
      return GetAllMedia(
        storeIdentity: storeIdentity,
        errorBuilder: errorBuilder,
        loadingBuilder: loadingBuilder,
        builder: builder,
      );
    }
    return GetMediaByCollectionId(
      storeIdentity: storeIdentity,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      parentId: parentId!,
      builder: builder,
    );
  }
}

class GetAvailableMediaByActiveCollectionId extends ConsumerWidget {
  const GetAvailableMediaByActiveCollectionId({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.storeIdentity,
    super.key,
  });
  final Widget Function(List<StoreEntity> items) builder;
  final Widget Function(String errorMsg) errorBuilder;
  final Widget Function() loadingBuilder;
  final String storeIdentity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parent = ref.watch(activeCollectionProvider);

    return GetAvailableMediaByCollectionId(
      storeIdentity: storeIdentity,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      parentId: parent?.id,
      builder: builder,
    );
  }
}
