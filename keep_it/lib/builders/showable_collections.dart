import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class GetShowableCollectionMultiple extends ConsumerWidget {
  const GetShowableCollectionMultiple({
    required this.builder,
    required this.errorBuilder,
    required this.loadingBuilder,
    super.key,
    this.queries = DBQueries.collectionsVisibleNotDeleted,
  });
  final Widget Function(
    Collections collections, {
    required bool isAllAvailable,
  }) builder;
  final Widget Function(Object, StackTrace)? errorBuilder;
  final Widget Function()? loadingBuilder;
  final DBQueries queries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canSync =
        ref.watch(serverProvider.select((server) => server.canSync));

    return GetCollectionMultiple(
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      query: DBQueries.collectionsVisibleNotDeleted,
      builder: (collections) {
        final Collections visibleCollections;
        if (!canSync) {
          visibleCollections = Collections(
            collections.entries
                .where(
                  (c) => !c.hasServerUID || (c.hasServerUID && c.haveItOffline),
                )
                .toList(),
          );
        } else {
          visibleCollections = collections;
        }

        return builder(
          collections,
          isAllAvailable:
              visibleCollections.entries.length == collections.entries.length,
        );
      },
    );
  }
}
