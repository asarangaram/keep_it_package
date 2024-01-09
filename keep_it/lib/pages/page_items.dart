import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'views/items/items_view.dart';
import 'views/load_from_store/load_from_store.dart';
import 'views/main/background.dart';

class ItemsPage extends ConsumerWidget {
  const ItemsPage({super.key, required this.clusterID});

  final int clusterID;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLFullscreenBox(
      useSafeArea: false,
      child: CLBackground(
        hasBackground: true,
        brighnessFactor: 0.25,
        child: LoadItems(
          clusterID: clusterID,
          buildOnData: (Items items) {
            return ItemsView(items: items);
          },
        ),
      ),
    );
  }
}
