import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'paginated_grid.dart';

class CollectionsGrid extends ConsumerWidget {
  const CollectionsGrid({
    required this.quickMenuScopeKey,
    required this.collectionList,
    super.key,
  });
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;
  final List<Collection> collectionList;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (collectionList.isEmpty) {
      throw Exception("This widget can't handle empty colections");
    }

    return LayoutBuilder(
      builder: (context, BoxConstraints constraints) {
        return PaginatedGrid(
          collections: collectionList,
          constraints: constraints,
          quickMenuScopeKey: quickMenuScopeKey,
        );
      },
    );
  }
}

/*
Not used yet.
class CollectionGridFromDB extends ConsumerWidget {
  const CollectionGridFromDB({
    super.key,
    required this.quickMenuScopeKey,
  });
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider(null));
    return collectionsAsync.when(
        loading: () => const CLLoadingView(),
        error: (err, _) => CLErrorView(errorMessage: err.toString()),
        data: (collections) {
          return CollectionsGrid(
              collectionList: collections.entries,
              quickMenuScopeKey: quickMenuScopeKey);
        });
  }
}
*/
