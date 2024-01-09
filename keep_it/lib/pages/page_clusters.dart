import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'views/load_from_store/load_clusters.dart';
import 'views/clusters/clusters_view.dart';

class ClustersPage extends ConsumerWidget {
  const ClustersPage({super.key, required this.collectionId});

  final int? collectionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => LoadClusters(
        collectionID: collectionId,
        buildOnData: (clusters) => ClustersView(clusters: clusters),
      );
}
