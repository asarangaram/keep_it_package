import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

class GetAvailableMediaByCollectionId extends ConsumerWidget {
  const GetAvailableMediaByCollectionId({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
  });
  final Widget Function(CLMedias items) builder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    final canSync =
        ref.watch(serverProvider.select((server) => server.canSync));
    return GetMediaByCollectionId(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      collectionId: collectionId,
      builder: (items) {
        CLMedias available;
        if (!canSync) {
          available = CLMedias(
            items.entries
                .where(
                  (c) => c.isCached,
                )
                .toList(),
          );
        } else {
          available = items;
        }
        return builder(available);
      },
    );
  }
}
