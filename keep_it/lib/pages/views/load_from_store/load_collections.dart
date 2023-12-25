import 'package:app_loader/app_loader.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../main/background.dart';

class LoadCollections extends ConsumerWidget {
  const LoadCollections({
    super.key,
    this.clusterID,
    required this.buildOnData,
    this.hasBackground = true,
  });
  final Widget Function(Collections collections) buildOnData;
  final int? clusterID;
  final bool hasBackground;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionsAsync = ref.watch(collectionsProvider(clusterID));
    return collectionsAsync.when(
        loading: () => CLBackground(
            hasBackground: hasBackground,
            brighnessFactor: 0.3,
            child: const CLLoadingView()),
        error: (err, _) => CLBackground(
            hasBackground: hasBackground,
            brighnessFactor: 0.3,
            child: CLErrorView(errorMessage: err.toString())),
        data: (collections) => CLBackground(
            hasBackground: hasBackground,
            brighnessFactor: collections.isNotEmpty ? 0.25 : 0,
            child: buildOnData(collections)));
  }
}
