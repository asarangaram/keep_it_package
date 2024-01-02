import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'collections_view.dart';
import 'keepit_dialogs.dart';

class CollectionsEmpty extends ConsumerWidget {
  const CollectionsEmpty({
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final availableSuggestions = ref.watch(availableSuggestionsProvider(null));
    // no need to check empty here as no collection created yet
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CLText.large("Create your first collection"),
          const SizedBox(
            height: 32,
          ),
          CLButtonsGrid(
            children2D: [
              [
                CLMenuItem("Suggested\nCollections", Icons.menu,
                    onTap: () => KeepItDialogs.onSuggestions(context,
                            availableSuggestions: availableSuggestions,
                            onSelectionDone:
                                (List<Collection> selectedCollections) {
                          ref
                              .read(collectionsProvider(null).notifier)
                              .upsertCollections(selectedCollections);
                        })),
                CLMenuItem("Create New", Icons.new_label,
                    onTap: () => KeepItDialogs.upsertCollection(context))
              ]
            ],
          )
        ],
      ),
    );
  }
}
