import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../../../data/providers/suggested_collections.dart';
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
  bool isGridView = true;

  @override
  Widget build(BuildContext context) {
    final availableSuggestions =
        ref.watch(availableSuggestionsProvider(widget.collections.entries));
    final menuItems = [
      [
        CLMenuItem(
          title: 'Suggested\nCollections',
          icon: Icons.menu,
          onTap: () async {
            KeepItDialogs.onSuggestions(
              context,
              availableSuggestions: availableSuggestions,
              onSelectionDone: (List<Collection> selectedCollections) {
                ref
                    .read(collectionsProvider(null).notifier)
                    .upsertCollections(selectedCollections);
              },
            );

            return true;
          },
        ),
        CLMenuItem(
          title: 'Create New',
          icon: Icons.new_label,
          onTap: () async {
            return KeepItDialogs.upsertCollection(
              context,
            );
          },
        ),
      ]
    ];

    if (widget.collections.isEmpty) {
      return KeepItMainView(
        pageBuilder: (context, quickMenuScopeKey) => CollectionsEmpty(
          menuItems: menuItems,
        ),
      );
    }
    return KeepItMainView(
      title: 'Collections',
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
              menuBuilder: (
                context,
                boxconstraints, {
                required void Function() onDone,
              }) {
                return CLButtonsGrid(
                  scaleType: CLScaleType.veryLarge,
                  size: const Size(
                    kMinInteractiveDimension * 1.5,
                    kMinInteractiveDimension * 1.5,
                  ),
                  children2D: menuItems.insertOnDone(onDone),
                );
              },
              child: const CLIcon.standard(Icons.add),
            );
          }
        },
        toggleGridView,
      ],
      pageBuilder: (context, quickMenuScopeKey) {
        if (isGridView) {
          return CollectionsGrid(
            quickMenuScopeKey: quickMenuScopeKey,
            collectionList: widget.collections.entries,
            onTapCollection: (context, collection) async {
              unawaited(
                context.push(
                  '/clusters/by_collection_id/${collection.id}',
                ),
              );
              return true;
            },
            onEditCollection: onEditCollection,
            onDeleteCollection: onDeleteCollection,
          );
        }
        return CollectionsList(
          collectionList: widget.collections.entries,
          onTapCollection: (context, collection) async {
            unawaited(
              context.push(
                '/clusters/by_collection_id/${collection.id}',
              ),
            );
            return true;
          },
          onEditCollection: onEditCollection,
          onDeleteCollection: onDeleteCollection,
        );
      },
    );
  }

  Widget toggleGridView(
    BuildContext context,
    GlobalKey<State<StatefulWidget>> quickMenuScopeKey,
  ) =>
      CLButtonIcon.small(
        isGridView ? Icons.view_list : Icons.widgets,
        onTap: () {
          setState(() {
            isGridView = !isGridView;
          });
        },
      );
  Future<bool?> onEditCollection(
    BuildContext context,
    Collection collection,
  ) async {
    return KeepItDialogs.upsertCollection(
      context,
      collection: collection,
    );
  }

  Future<bool?> onDeleteCollection(
    BuildContext context,
    Collection collection,
  ) async {
    switch (await showOkCancelAlertDialog(
      context: context,
      message: 'Are you sure that you want to delete?',
      okLabel: 'Yes',
      cancelLabel: 'No',
    )) {
      case OkCancelResult.ok:
        ref
            .read(collectionsProvider(null).notifier)
            .deleteCollection(collection);
        return true;
      case OkCancelResult.cancel:
        return false;
    }
  }
}
