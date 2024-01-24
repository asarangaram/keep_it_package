import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../widgets/load_from_store.dart';
import '../views/clusters_view.dart';

class ClustersPage extends ConsumerWidget {
  const ClustersPage({required this.collectionId, super.key});

  final int? collectionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => CLFullscreenBox(
        child: CLBackground(
          child: LoadClusters(
            collectionID: collectionId,
            buildOnData: (clusters) => ClustersView(clusters: clusters),
          ),
        ),
      );
}
