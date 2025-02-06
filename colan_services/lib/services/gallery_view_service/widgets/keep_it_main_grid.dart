import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

import '../../../internal/entity_grid/gallery_view.dart';
import '../../context_menu_service/models/context_menu_items.dart';
import '../../media_view_service/preview/entity_preview.dart';
import '../../media_view_service/widgets/stale_media_indicator_service.dart';
import '../providers/active_collection.dart';
import 'actions/bottom_bar.dart';
import 'actions/top_bar.dart';
import 'view_modifier_builder.dart';
import 'when_empty.dart';

class KeepItMainGrid extends ConsumerWidget {
  const KeepItMainGrid({
    required this.parentIdentifier,
    required this.clmedias,
    required this.theStore,
    required this.loadingBuilder,
    required this.errorBuilder,
    super.key,
  });
  final String parentIdentifier;
  final CLMedias clmedias;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final StoreUpdater theStore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final collectionId = ref.watch(activeCollectionProvider);
    final viewIdentifier = ViewIdentifier(
      parentID: parentIdentifier,
      viewId: collectionId.toString(),
    );
    if (clmedias.isEmpty && collectionId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(activeCollectionProvider.notifier).state = null;
      });
    }
    return Column(
      children: [
        KeepItTopBar(
          parentIdentifier: parentIdentifier,
          clmedias: clmedias,
          theStore: theStore,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: /* isSelectionMode ? null : */
                () async => theStore.store.reloadStore(),
            child: clmedias.entries.isEmpty
                ? const WhenEmpty()
                : ViewModifierBuilder(
                    viewIdentifier: viewIdentifier,
                    entities: clmedias.entries,
                    filtersDisabled: false,
                    onSelectionChanged: null,
                    bannersBuilder: (context, _) {
                      return [
                        if (collectionId == null)
                          const StaleMediaIndicatorService(),
                      ];
                    },
                    contextMenuOf: (context, entities) =>
                        CLContextMenu.entitiesContextMenuBuilder(
                      context,
                      ref,
                      entities,
                      theStore,
                    ),
                    itemBuilder: (
                      context,
                      item, {
                      required CLEntity? Function(CLEntity entity)? onGetParent,
                      required List<CLEntity>? Function(CLEntity entity)?
                          onGetChildren,
                    }) =>
                        EntityPreview(
                      viewIdentifier: viewIdentifier,
                      item: item,
                      theStore: theStore,
                      onGetChildren: onGetChildren,
                      onGetParent: onGetParent,
                    ),
                    builder: ({
                      required incoming,
                      required itemBuilder,
                      required labelBuilder,
                      required viewIdentifier,
                      required bannersBuilder,
                      required draggableMenuBuilder,
                    }) {
                      return EntityGridView(
                        viewIdentifier: viewIdentifier,
                        errorBuilder: errorBuilder,
                        loadingBuilder: loadingBuilder,
                        incoming: incoming,
                        columns: 3,
                        viewableAsCollection: collectionId == null,
                        itemBuilder: itemBuilder,
                        labelBuilder: labelBuilder,
                        bannersBuilder: bannersBuilder,
                        draggableMenuBuilder: draggableMenuBuilder,
                      );
                    },
                  ),
          ),
        ),
        if (MediaQuery.of(context).viewInsets.bottom == 0)
          const KeepItBottomBar(),
      ],
    );
  }
}
