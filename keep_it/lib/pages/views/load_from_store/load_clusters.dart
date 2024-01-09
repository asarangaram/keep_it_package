import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
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
    final brighnessFactor = clustersAsync.whenOrNull(
            data: (clusters) => clusters.isEmpty ? 0.0 : null) ??
        0.25;
    return CLFullscreenBox(
      useSafeArea: false,
      child: CLBackground(
        hasBackground: hasBackground,
        brighnessFactor: brighnessFactor,
        child: clustersAsync.when(
            loading: () => const CLLoadingView(),
            error: (err, _) => CLErrorView(errorMessage: err.toString()),
            data: (clusters) => buildOnData(clusters)),
      ),
    );
  }
}
