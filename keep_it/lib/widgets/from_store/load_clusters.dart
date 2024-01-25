import 'package:app_loader/app_loader.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

class LoadClusters extends ConsumerWidget {
  const LoadClusters({
    required this.buildOnData,
    super.key,
    this.collectionID,
    this.hasBackground = true,
  });
  final Widget Function(Clusters clusters) buildOnData;
  final int? collectionID;
  final bool hasBackground;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clustersAsync = ref.watch(clustersProvider(collectionID));

    return clustersAsync.when(
      loading: () => const CLLoadingView(),
      error: (err, _) => CLErrorView(errorMessage: err.toString()),
      data: buildOnData,
    );
  }
}
