import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/services/gallery_view_service/models/entity_actions.dart';
import 'package:colan_services/services/gallery_view_service/widgets/c_l_selectable_grid_scope.dart';
import 'package:colan_services/services/gallery_view_service/widgets/cl_scaffold.dart';
import 'package:colan_services/services/gallery_view_service/widgets/entity_preview.dart';
import 'package:colan_services/services/gallery_view_service/widgets/on_swipe.dart';
import 'package:colan_services/services/gallery_view_service/widgets/refresh_button.dart';
import 'package:colan_services/services/gallery_view_service/widgets/stale_media_banner.dart';
import 'package:colan_services/services/gallery_view_service/widgets/when_empty.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'bottom_bar_grid_view.dart';
import 'top_bar_grid_view.dart';

class EntityGridView extends ConsumerWidget {
  const EntityGridView({
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
        bottomMenu: BottomBarGridView(
          storeIdentity: storeIdentity,
          entity: parent,
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
