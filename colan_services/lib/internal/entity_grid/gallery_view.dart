import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart' show ViewerEntityMixin;

import 'widgets/gallery_view.dart';

class EntityGridView extends StatelessWidget {
  const EntityGridView({
    required this.viewIdentifier,
    required this.columns,
    required this.incoming,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.viewableAsCollection,
    required this.itemBuilder,
    required this.labelBuilder,
    required this.bannersBuilder,
    super.key,
    this.draggableMenuBuilder,
  });
  final ViewIdentifier viewIdentifier;
  final int columns;
  final List<ViewerEntityMixin> incoming;

  final Widget Function(String errorMsg) errorBuilder;
  final Widget Function() loadingBuilder;
  final Widget Function(BuildContext, ViewerEntityMixin) itemBuilder;
  final Widget? Function(
    BuildContext context,
    List<GalleryGroupStoreEntity<ViewerEntityMixin>> galleryMap,
    GalleryGroupStoreEntity<ViewerEntityMixin> gallery,
  ) labelBuilder;
  final List<Widget> Function(
    BuildContext context,
    List<GalleryGroupStoreEntity<ViewerEntityMixin>> galleryMap,
  ) bannersBuilder;
  final Widget Function(
    BuildContext, {
    required GlobalKey<State<StatefulWidget>> parentKey,
  })? draggableMenuBuilder;

  final bool viewableAsCollection;

  @override
  Widget build(BuildContext context) {
    return GetGroupedMedia(
      viewIdentifier: viewIdentifier,
      errorBuilder: errorBuilder,
      loadingBuilder: loadingBuilder,
      incoming: incoming,
      columns: columns,
      viewableAsCollection: viewableAsCollection,
      builder: (
        tabs,
        /* columns */
      ) {
        return RawCLEntityGalleryView(
          viewIdentifier: viewIdentifier,
          tabs: tabs,
          bannersBuilder: bannersBuilder,
          labelBuilder: labelBuilder,
          itemBuilder: itemBuilder,
          columns: columns,
          draggableMenuBuilder: draggableMenuBuilder,
        );
      },
    );
  }
}
