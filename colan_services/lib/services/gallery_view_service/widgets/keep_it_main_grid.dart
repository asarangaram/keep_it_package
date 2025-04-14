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
    required this.entities,
    required this.theStore,
    required this.loadingBuilder,
    required this.errorBuilder,
    required this.storeIdentity,
    super.key,
  });
  final String parentIdentifier;
  final List<StoreEntity> entities;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final CLStore theStore;
  final String storeIdentity;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentId = ref.watch(activeCollectionProvider);
    final viewIdentifier = ViewIdentifier(
      parentID: parentIdentifier,
      viewId: parentId.toString(),
    );
    if (entities.isEmpty && parentId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(activeCollectionProvider.notifier).state = null;
      });
    }
    return Column(
      children: [
        KeepItTopBar(
          parentIdentifier: parentIdentifier,
          entities: entities,
          theStore: theStore,
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: /* isSelectionMode ? null : */
                () async => ref.read(reloadProvider.notifier).reload(),
            child: entities.isEmpty
                ? const WhenEmpty()
                : ViewModifierBuilder(
                    viewIdentifier: viewIdentifier,
                    entities: entities,
                    filtersDisabled: false,
                    onSelectionChanged: null,
                    bannersBuilder: (context, _) {
                      return [
                        if (parentId == null)
                          StaleMediaIndicatorService(
                            storeIdentity: storeIdentity,
                          ),
                      ];
                    },
                    contextMenuOf: (context, entities) =>
                        CLContextMenu.entitiesContextMenuBuilder(
                      context,
                      ref,
                      entities,
                      theStore,
                    ),
                    itemBuilder: (context, item) => EntityPreview(
                      viewIdentifier: viewIdentifier,
                      item: item,
                      theStore: theStore,
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
                        storeIdentity: storeIdentity,
                        errorBuilder: errorBuilder,
                        loadingBuilder: loadingBuilder,
                        incoming: incoming,
                        columns: 3,
                        viewableAsCollection: parentId == null,
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
          KeepItBottomBar(
            storeIdentity: storeIdentity,
          ),
      ],
    );
  }
}
