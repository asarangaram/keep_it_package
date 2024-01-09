import 'package:app_loader/app_loader.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

class LoadCollections extends ConsumerWidget {
  const LoadCollections({
    super.key,
    this.clusterID,
    required this.buildOnData,
  });
  final Widget Function(Collections collections) buildOnData;
  final int? clusterID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider(clusterID));

    return collectionsAsync.when(
        loading: () => const CLLoadingView(),
        error: (err, _) => CLErrorView(errorMessage: err.toString()),
        data: (collections) => buildOnData(collections));
  }
}

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
        loading: () => const CLLoadingView(),
        error: (err, _) => CLErrorView(errorMessage: err.toString()),
        data: (clusters) => buildOnData(clusters));
  }
}

class LoadItems extends ConsumerWidget {
  const LoadItems({
    super.key,
    required this.clusterID,
    required this.buildOnData,
    this.hasBackground = true,
  });
  final Widget Function(Items items) buildOnData;
  final int clusterID;
  final bool hasBackground;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemsAsync = ref.watch(itemsProvider(clusterID));
    return itemsAsync.when(
        loading: () => const CLLoadingView(),
        error: (err, _) => CLErrorView(errorMessage: err.toString()),
        data: (items) => buildOnData(items));
  }
}
