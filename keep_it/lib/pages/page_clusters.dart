import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import 'views/clusters/clusters_view.dart';
import 'views/load_from_store/load_clusters.dart';
import 'views/main/keep_it_main_view.dart';

class ClusterPage extends ConsumerWidget {
  const ClusterPage({super.key, required this.collectionId});
  final int? collectionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLFullscreenBox(
      useSafeArea: false,
      child: LoadClusters(
        collectionID: collectionId,
        buildOnData: (clusters) => ClustersView(clusters: clusters),
      ),
    );
  }
}
