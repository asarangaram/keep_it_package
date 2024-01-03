import 'package:app_loader/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../main/background.dart';

class LoadClusters extends ConsumerWidget {
  const LoadClusters({
    super.key,
    this.collectionID,
    required this.buildOnData,
    this.hasBackground = true,
  });
  final Widget Function(Clusters clusters) buildOnData;
  final int? collectionID;
  final bool hasBackground;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clustersAsync = ref.watch(clustersProvider(collectionID));
    return clustersAsync.when(
        loading: () => CLBackground(
            hasBackground: hasBackground,
            brighnessFactor: 0.3,
            child: const CLLoadingView()),
        error: (err, _) => CLBackground(
            hasBackground: hasBackground,
            brighnessFactor: 0.3,
            child: CLErrorView(errorMessage: err.toString())),
        data: (clusters) => CLBackground(
            hasBackground: hasBackground,
            brighnessFactor: clusters.isNotEmpty ? 0.25 : 0,
            child: buildOnData(clusters)));
  }
}
