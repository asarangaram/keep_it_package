import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

class LoadItems extends ConsumerWidget {
  const LoadItems({
    required this.collectionID,
    required this.buildOnData,
    super.key,
    this.hasBackground = true,
  });
  final Widget Function(CLMediaList items) buildOnData;
  final int collectionID;
  final bool hasBackground;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync =
        ref.watch(clMediaListByCollectionIdProvider(collectionID));

    return itemsAsync.when(
      loading: () => const CLLoadingView(),
      error: (err, _) => CLErrorView(errorMessage: err.toString()),
      data: buildOnData,
    );
  }
}
