import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/services/gallery_view_service/widgets/cl_scaffold.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/entity_actions.dart';
import 'widgets/bottom_bar.dart';
import 'widgets/c_l_selectable_grid_scope.dart';
import 'widgets/entity_preview.dart';
import 'widgets/on_swipe.dart';
import 'widgets/refresh_button.dart';
import 'widgets/stale_media_banner.dart';
import 'widgets/top_bar_grid_view.dart';
import 'widgets/when_empty.dart';

class GalleryViewService extends ConsumerWidget {
  const GalleryViewService({
    required this.viewIdentifier,
    required this.storeIdentity,
    required this.parent,
    required this.children,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final String storeIdentity;
  final ViewerEntityMixin? parent;
  final List<ViewerEntityMixin> children;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return CLSelectableGridScope(
      child: CLScaffold(
        topMenu: TopBarGridView(
          viewIdentifier: viewIdentifier,
          storeIdentity: storeIdentity,
          parent: parent,
          children: children,
        ),
        banners: [
          if (parent == null)
            StaleMediaBanner(
              storeIdentity: storeIdentity,
            ),
        ],
        bottomMenu: KeepItBottomBar(
          storeIdentity: storeIdentity,
          id: parent?.id,
        ),
        body: OnSwipe(
          child: SafeArea(
            bottom: false,
            child: OnRefreshWrapper(
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: CLGalleryGridView(
                  viewIdentifier: viewIdentifier,
                  incoming: children,
                  filtersDisabled: false,
                  onSelectionChanged: null,
                  contextMenuBuilder: (context, entities) =>
                      EntityActions.entities(
                    context,
                    ref,
                    entities,
                  ),
                  itemBuilder: (context, item, entities) => EntityPreview(
                    viewIdentifier: viewIdentifier,
                    item: item,
                    entities: entities,
                    parentId: parent?.id,
                  ),
                  whenEmpty: const WhenEmpty(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
/* 
class GalleryViewService0 extends ConsumerWidget {
  const GalleryViewService0({
    required this.storeIdentity,
    required this.parentIdentifier,
    required this.parent,
    required this.entities,
    super.key,
  });

  final String storeIdentity;
  final String parentIdentifier;
  final ViewerEntityMixin? parent;
  final List<ViewerEntityMixin> entities;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentId = parent?.id;
    final viewIdentifier = ViewIdentifier(
      parentID: parentIdentifier,
      viewId: (parent?.id).toString(),
    );

    if (entities.isEmpty && parent?.id != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (PageManager.of(context).canPop()) {
          PageManager.of(context).pop();
        }
      });
    }
    return Column(
      children: [
        if (parentId == null)
          StaleMediaBanner(
            storeIdentity: storeIdentity,
          ),
        Expanded(
          child: OnRefreshWrapper(
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: CLGalleryGridView(
                viewIdentifier: viewIdentifier,
                incoming: entities,
                filtersDisabled: false,
                onSelectionChanged: null,
                contextMenuBuilder: (context, entities) =>
                    EntityActions.entities(
                  context,
                  ref,
                  entities,
                ),
                itemBuilder: (context, item, entities) => EntityPreview(
                  viewIdentifier: viewIdentifier,
                  item: item,
                  entities: entities,
                  parentId: parentId,
                ),
                whenEmpty: const WhenEmpty(),
              ),
            ),
          ),
        ),
        if (MediaQuery.of(context).viewInsets.bottom == 0)
          KeepItBottomBar(
            storeIdentity: storeIdentity,
            id: parentId,
          ),
      ],
    );
  }
}
 */
