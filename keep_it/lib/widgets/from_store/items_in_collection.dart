import 'package:app_loader/app_loader.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

class LoadItemsInCollection extends ConsumerWidget {
  const LoadItemsInCollection({
    required this.id,
    required this.buildOnData,
    super.key,
    this.limit,
  });
  final Widget Function(List<Item> items) buildOnData;
  final int id;
  final int? limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(
      itemsByCollectionIdProvider(
        DBQueries.byCollectionID(id, limit: limit),
      ),
    );

    return itemsAsync.when(
      loading: () => const CLLoadingView(),
      error: (err, _) => CLErrorView(errorMessage: err.toString()),
      data: buildOnData,
    );
  }
}
