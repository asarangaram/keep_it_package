import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../widgets/load_from_store.dart';
import '../views/items_view.dart';

class ItemsPage extends ConsumerWidget {
  const ItemsPage({required this.clusterID, super.key});

  final int clusterID;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLFullscreenBox(
      child: CLBackground(
        child: LoadItems(
          clusterID: clusterID,
          buildOnData: (Items items, {required String docDir}) {
            return ItemsView(items: items);
          },
        ),
      ),
    );
  }
}
