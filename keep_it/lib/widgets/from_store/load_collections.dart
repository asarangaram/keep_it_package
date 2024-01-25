import 'package:app_loader/app_loader.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

class LoadTags extends ConsumerWidget {
  const LoadTags({
    required this.buildOnData,
    super.key,
    this.clusterID,
  });
  final Widget Function(Tags collections) buildOnData;
  final int? clusterID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider(clusterID));

    return collectionsAsync.when(
      loading: () => const CLLoadingView(),
      error: (err, _) => CLErrorView(errorMessage: err.toString()),
      data: buildOnData,
    );
  }
}
