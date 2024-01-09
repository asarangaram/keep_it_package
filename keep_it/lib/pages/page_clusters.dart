import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'views/clusters/clusters_view.dart';
import 'views/load_from_store/load_from_store.dart';
import 'views/main/background.dart';

class ClustersPage extends ConsumerWidget {
  const ClustersPage({super.key, required this.collectionId});

  final int? collectionId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => CLFullscreenBox(
        useSafeArea: false,
        child: CLBackground(
          hasBackground: true,
          brighnessFactor: 0.25,
          child: LoadClusters(
            collectionID: collectionId,
            buildOnData: (clusters) => ClustersView(clusters: clusters),
          ),
        ),
      );
}
