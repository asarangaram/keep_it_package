import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/db_items.dart';

class LoadItems extends ConsumerWidget {
  const LoadItems({
    required this.collectionId,
    required this.buildOnData,
    super.key,
    this.hasBackground = true,
  });
  final Widget Function(CLMediaList items) buildOnData;
  final int collectionId;
  final bool hasBackground;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync =
        ref.watch(clMediaListByCollectionIdProvider(collectionId));

    return itemsAsync.when(
      loading: () => const CLLoadingView(),
      error: (err, _) => CLErrorView(errorMessage: err.toString()),
      data: buildOnData,
    );
  }
}

class LoadItemsInTag extends ConsumerWidget {
  const LoadItemsInTag({
    required this.buildOnData,
    required this.id,
    super.key,
    this.limit,
  });
  final Widget Function(List<CLMedia>? items) buildOnData;
  final int id;
  final int? limit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(clMediaListByTagIdProvider(id));

    return itemsAsync.when(
      loading: () => const CLLoadingView(),
      error: (err, _) => CLErrorView(errorMessage: err.toString()),
      data: buildOnData,
    );
  }
}
