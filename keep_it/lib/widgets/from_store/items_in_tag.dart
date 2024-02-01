import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

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
    final itemsAsync = ref.watch(itemsByTagIdProvider(DBQueries.byTagID(id)));

    return itemsAsync.when(
      loading: () => const CLLoadingView(),
      error: (err, _) => CLErrorView(errorMessage: err.toString()),
      data: buildOnData,
    );
  }
}
