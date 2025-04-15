import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/services/gallery_view_service/widgets/when_empty.dart';

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
    return CLGalleryGridView(
      viewIdentifier: viewIdentifier,
      incoming: {'Media': incoming},
      bannersBuilder: bannersBuilder,
      labelBuilder: labelBuilder,
      itemBuilder: itemBuilder,
      columns: columns,
      draggableMenuBuilder: draggableMenuBuilder,
      whenEmpty: const WhenEmpty(),
    );
  }
}
