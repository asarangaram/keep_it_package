import 'dart:async';

import 'package:adaptive_dialog/adaptive_dialog.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:store/store.dart';

import '../widgets/collections_dialogs.dart';
import '../widgets/collections_empty.dart';
import '../widgets/collections_grid.dart';
import '../widgets/collections_list.dart';
import '../widgets/keep_it_main_view.dart';
import '../widgets/load_from_store.dart';

class CollectionsView extends ConsumerWidget {
  const CollectionsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => const CLFullscreenBox(
        child: CLBackground(
          child: LoadCollections(
            buildOnData: _CollectionsView.new,
          ),
        ),
      );
}

class _CollectionsView extends ConsumerStatefulWidget {
  const _CollectionsView(this.collections, {super.key});
  final Collections collections;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CollectionsViewState();
}

class _CollectionsViewState extends ConsumerState<_CollectionsView> {
  @override
  Widget build(BuildContext context) {
    final availableSuggestions = widget.collections.getSuggestions;

    final menuItems = [
      [
        CLMenuItem(
          title: 'Suggested\nCollections',
          icon: Icons.menu,
          onTap: () async {
            CollectionsDialog.onSuggestions(
              context,
              availableSuggestions: availableSuggestions.entries,
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
            return CollectionsDialog.upsertCollection(
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
              onTap: () => CollectionsDialog.upsertCollection(context),
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
        final isGridView = ref.watch(isGridProvider);
        if (isGridView) {
          return CollectionsGrid(
            quickMenuScopeKey: quickMenuScopeKey,
            collections: widget.collections,
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
          collections: widget.collections,
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
  ) {
    final isGridView = ref.watch(isGridProvider);
    return CLButtonIcon.small(
      isGridView ? Icons.view_list : Icons.widgets,
      onTap: () {
        ref.read(isGridProvider.notifier).state = !isGridView;
      },
    );
  }

  Future<bool?> onEditCollection(
    BuildContext context,
    Collection collection,
  ) async {
    return CollectionsDialog.upsertCollection(
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

// should be part of settings.
final isGridProvider = StateProvider<bool>((ref) {
  return true;
});
