import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
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

    final brighnessFactor = collectionsAsync.whenOrNull(
            data: (collections) => collections.isEmpty ? 0.0 : null) ??
        0.25;
    return CLFullscreenBox(
      useSafeArea: false,
      child: CLBackground(
        hasBackground: hasBackground,
        brighnessFactor: brighnessFactor,
        child: collectionsAsync.when(
            loading: () => const CLLoadingView(),
            error: (err, _) => CLErrorView(errorMessage: err.toString()),
            data: (collections) => buildOnData(collections)),
      ),
    );
  }
}
