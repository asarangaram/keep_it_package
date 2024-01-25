import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'load_clusters.dart';

// TODO(anandas): Can we query ClusterCount from DB?
class ClusterCount extends ConsumerWidget {
  const ClusterCount({
    required this.collectionId,
    required this.buildOnData,
    super.key,
  });
  final int? collectionId;

  final Widget Function(int count) buildOnData;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoadClusters(
      collectionID: collectionId,
      buildOnData: (clusters) {
        return buildOnData(clusters.entries.length);
      },
    );
  }
}
