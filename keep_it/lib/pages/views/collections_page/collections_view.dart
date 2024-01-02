import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../data/db_default_collections.dart';
import '../main/keep_it_main_view.dart';

import 'collections_empty.dart';
import 'collections_grid.dart';
import 'collections_list.dart';
import 'keepit_dialogs.dart';

class CollectionsView extends ConsumerStatefulWidget {
  const CollectionsView(this.collections, {super.key});
  final Collections collections;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => CollectionsViewState();
}

class CollectionsViewState extends ConsumerState<CollectionsView> {
  bool isGridView = false;

  @override
  Widget build(BuildContext context) {
    final availableSuggestions =
        ref.watch(availableSuggestionsProvider(widget.collections.entries));
    if (widget.collections.isEmpty) {
      return KeepItMainView(
        pageBuilder: (context, quickMenuScopeKey) => const CollectionsEmpty(),
      );
    }
    return KeepItMainView(
      title: "Collections",
      actionsBuilder: [
        (context, quickMenuScopeKey) {
          if (availableSuggestions.isEmpty) {
            return CLButtonIcon.standard(
              Icons.add,
              onTap: () => KeepItDialogs.upsertCollection(context),
            );
          } else {
            return CLQuickMenuAnchor(
              parentKey: quickMenuScopeKey,
              menuBuilder: (context, boxconstraints,
                  {required Function() onDone}) {
                return CLButtonsGrid(
                  scaleType: CLScaleType.veryLarge,
                  size: const Size(kMinInteractiveDimension * 1.5,
                      kMinInteractiveDimension * 1.5),
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
                                onDone();
                              })),
                      CLMenuItem("Create New", Icons.new_label,
                          onTap: () => KeepItDialogs.upsertCollection(context,
                              onDone: onDone))
                    ]
                  ],
                );
              },
              child: const CLIcon.standard(
                Icons.add,
              ),
            );
          }
        },
        (context, quickMenuScopeKey) => CLButtonIcon.small(
              isGridView ? Icons.view_list : Icons.widgets,
              onTap: () {
                setState(() {
                  isGridView = !isGridView;
                });
              },
            )
      ],
      pageBuilder: (context, quickMenuScopeKey) {
        if (isGridView) {
          return CollectionsGrid(
            quickMenuScopeKey: quickMenuScopeKey,
            collectionList: widget.collections.entries,
          );
        }
        return CollectionsList(
          collectionList: widget.collections.entries,
        );
      },
    );
  }
}

final availableSuggestionsProvider =
    StateProvider.family<List<Collection>, List<Collection>>(
        (ref, existingCollections) {
  final List<Collection> availableSuggestions;
  availableSuggestions = defaultCollections.where((element) {
    return !existingCollections.map((e) => e.label).contains(element.label);
  }).toList();

  return availableSuggestions;
});
