import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:keep_it/collection_view/items_gridview.dart';
import 'package:store/store.dart';

import '../widgets/dialogs.dart';
import '../widgets/from_store/from_store.dart';
import '../widgets/keep_it_main_view.dart';

class ItemsPage extends ConsumerWidget {
  const ItemsPage({required this.collectionID, super.key});

  final int collectionID;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoadItems(
      collectionID: collectionID,
      buildOnData: (Items items) {
        return KeepItMainView(
          title: items.collection.label,
          onPop: () {
            if (context.canPop()) {
              context.pop();
            }
          },
          actionsBuilder: [
            (context, quickMenuScopeKey) => CLButtonIcon.standard(
                  Icons.add,
                  onTap: () => KeepItDialogs.onAddItemsIntoCollection(
                    context,
                    ref,
                    items.collection,
                  ),
                ),
          ],
          pageBuilder: (context, quickMenuScopeKey) {
            return Padding(
              padding: const EdgeInsets.all(8),
              child: CLMediaGridView(
                label: items.collection.label,
                items: items.entries,
                columns: 2,
                //rows: 2,
              ),
            );
          },
        );
      },
    );
  }
}
