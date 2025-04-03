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
    super.key,
    this.parentId,
  });
  final int? parentId;
  final Widget Function(List<CLEntity> items) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetMediaByCollectionId(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      parentId: parentId,
      builder: builder,
    );
  }
}

class GetAvailableMediaByActiveCollectionId extends ConsumerWidget {
  const GetAvailableMediaByActiveCollectionId({
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
    final parentId = ref.watch(activeCollectionProvider);

    return GetAvailableMediaByCollectionId(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      parentId: parentId,
      builder: builder,
    );
  }
}
