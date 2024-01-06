import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../main/keep_it_main_view.dart';
import 'cluster_view.dart';

class ClustersView extends ConsumerWidget {
  const ClustersView({super.key, required this.clusters});
  final Clusters clusters;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return KeepItMainView(
      onPop: context.canPop()
          ? () {
              context.pop();
            }
          : null,
      pageBuilder: (context, quickMenuScopeKey) {
        return CLGridViewCustom(
          showAll: true,
          maxCrossAxisCount: 3,
          children:
              clusters.entries.map((e) => ClusterView(cluster: e)).toList(),
        );
      },
    );
  }
}
