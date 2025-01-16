import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class GetAvailableMediaByCollectionId extends ConsumerWidget {
  const GetAvailableMediaByCollectionId({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    this.collectionId,
    super.key,
  });
  final Widget Function(CLMedias items) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;
  final int? collectionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
                  (c) =>
                      !c.hasServerUID ||
                      (c.hasServerUID && (c.haveItOffline ?? false)),
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
