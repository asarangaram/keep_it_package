import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/services/gallery_view_service/widgets/when_empty.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';

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
    required this.storeIdentity,
    super.key,
    this.draggableMenuBuilder,
  });
  final ViewIdentifier viewIdentifier;
  final String storeIdentity;
  final int columns;
  final List<ViewerEntityMixin> incoming;

  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final Widget Function(BuildContext, ViewerEntityMixin) itemBuilder;
  final Widget? Function(
    BuildContext context,
    List<ViewerEntityGroup<ViewerEntityMixin>> galleryMap,
    ViewerEntityGroup<ViewerEntityMixin> gallery,
  ) labelBuilder;
  final List<Widget> Function(
    BuildContext context,
    List<ViewerEntityGroup<ViewerEntityMixin>> galleryMap,
  ) bannersBuilder;
  final Widget Function(
    BuildContext, {
    required GlobalKey<State<StatefulWidget>> parentKey,
  })? draggableMenuBuilder;

  final bool viewableAsCollection;

  @override
  Widget build(BuildContext context) {
    return GetGroupedMedia(
      storeIdentity: storeIdentity,
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
        return CLGalleryGridView(
          viewIdentifier: viewIdentifier,
          tabs: tabs,
          bannersBuilder: bannersBuilder,
          labelBuilder: labelBuilder,
          itemBuilder: itemBuilder,
          columns: columns,
          draggableMenuBuilder: draggableMenuBuilder,
          whenEmpty: const WhenEmpty(),
        );
      },
    );
  }
}
