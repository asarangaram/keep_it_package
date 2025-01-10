import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../navigation/providers/active_collection.dart';
import 'showable_collections.dart';

class GetMainViewEntities extends ConsumerWidget {
  const GetMainViewEntities({
    required this.builder,
    required this.loadingBuilder,
    required this.errorBuilder,
    super.key,
  });
  final Widget Function(List<CLEntity> entities) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    return collectionId == null
        ? GetShowableCollectionMultiple(
            errorBuilder: errorBuilder,
            loadingBuilder: loadingBuilder,
            builder: (
              Collections collections, {
              required bool isAllAvailable,
            }) {
              return builder(collections.entries);
            },
          )
        : GetMediaByCollectionId(
            errorBuilder: errorBuilder,
            loadingBuilder: loadingBuilder,
            collectionId: collectionId,
            builder: (media) {
              return builder(media.entries);
            },
          );
  }
}
