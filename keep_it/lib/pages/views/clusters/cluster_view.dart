import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import '../load_from_store/load_items.dart';
import '../receive_shared/media_preview.dart';

class ClusterView extends ConsumerWidget {
  const ClusterView({super.key, required this.cluster});
  final Cluster cluster;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes =
        (cluster.description.isEmpty) ? "No Description" : cluster.description;
    return LoadItems(
      clusterID: cluster.id,
      hasBackground: false,
      buildOnData: (items) {
        return MediaPreview.fromItems(
          items,
          children: [
            Padding(
              padding:
                  const EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  notes,
                  textAlign: TextAlign.start,
                ),
              ),
            )
          ],
        );
      },
    );
  }
}
