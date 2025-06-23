import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';
import 'package:store_tasks/src/widgets/pick_collection/server_label.dart';
import 'package:store_tasks/src/widgets/search_collection/search_view.dart';

import 'wizard_error.dart';

class CollectionAnchor extends ConsumerStatefulWidget {
  const CollectionAnchor(
      {required this.collection,
      required this.searchController,
      required this.onDone,
      super.key});
  final StoreEntity? collection;
  final SearchController searchController;
  final void Function(StoreEntity candidate) onDone;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CollectionAnchorState();
}

class _CollectionAnchorState extends ConsumerState<CollectionAnchor> {
  @override
  Widget build(BuildContext context) {
    return GetActiveStore(
        loadingBuilder: () => CLLoader.widget(debugMessage: null),
        errorBuilder: (e, st) {
          return WizardError(
            error: e.toString(),
            onClose: () => widget.searchController.closeView(null),
          );
        },
        builder: (activeStore) {
          return CollectionAnchor0(
            targetStore: widget.collection?.store ?? activeStore,
            collection: widget.collection,
            searchController: widget.searchController,
          );
        });
  }
}

class CollectionAnchor0 extends ConsumerWidget {
  const CollectionAnchor0(
      {required this.collection,
      required this.searchController,
      required this.targetStore,
      super.key});
  final StoreEntity? collection;
  final SearchController searchController;
  final CLStore targetStore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SearchAnchor(
      searchController: searchController,
      isFullScreen: true,
      viewBuilder: (suggestions) {
        return SearchView(
          targetStore: targetStore,
          onFailed: () => searchController.closeView(null),
          searchController: searchController,
        );
      },
      suggestionsBuilder: (context, controller) {
        final suggestions = <Widget>[];
        /* if (controller.text.isEmpty) {
          suggestions.addAll(entities.entities.map((e) => Center(
                child: GetEntities(
                    parentId: e.id,
                    errorBuilder: (_, __) => const BrokenImage(),
                    loadingBuilder: () => const GreyShimmer(),
                    builder: (children) {
                      return CLEntityView(entity: e, children: children);
                    }),
              )));
        } else {
          suggestions.addAll(entities.entities
              .where((e) => e.label!.startsWith(searchController.text))
              .map((e) => GetEntities(
                  parentId: e.id,
                  errorBuilder: (_, __) => const BrokenImage(),
                  loadingBuilder: () => const GreyShimmer(),
                  builder: (children) {
                    return CLEntityView(entity: e, children: children);
                  })));
        }
        suggestions.add(Container(
          child: const Icon(Icons.add),
        )); */
        return suggestions;
      },
      builder: (context, controller) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          spacing: 8,
          children: [
            Expanded(
              flex: 13,
              child: Align(
                alignment: Alignment.bottomCenter,
                child: TextFormField(
                  initialValue: collection?.label,
                  decoration: collection == null
                      ? InputDecoration(
                          hintStyle: ShadTheme.of(context).textTheme.muted,
                          hintText: 'Tap here to select a collection')
                      : null,
                  readOnly: true,
                  showCursor: false,
                  enableInteractiveSelection: false,
                  onTap: searchController.openView,
                ),
              ),
            ),
            Expanded(
              flex: 7,
              child: Align(
                  alignment: Alignment.centerRight,
                  child: collection == null
                      ? null
                      : ServerLabel(
                          store: collection!.store,
                        )),
            )
          ],
        );
      },
    );
  }
}
