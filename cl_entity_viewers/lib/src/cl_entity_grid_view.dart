import 'package:flutter/material.dart';

import 'models/cl_entities.dart';
import 'models/gallery_group.dart';
import 'models/labeled_entity_groups.dart';
import 'models/media_grouper.dart';
import 'models/tab_identifier.dart';
import 'widgets/gallery_view.dart';

class CLEntityGridView extends StatelessWidget {
  const CLEntityGridView({
    required this.viewIdentifier,
    required this.columns,
    required this.incoming,
    required this.errorBuilder,
    required this.loadingBuilder,
    required this.itemBuilder,
    required this.labelBuilder,
    required this.bannersBuilder,
    super.key,
    this.draggableMenuBuilder,
  });
  final ViewIdentifier viewIdentifier;
  final int columns;
  final List<CLEntity> incoming;

  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function() loadingBuilder;
  final Widget Function(
    BuildContext,
    CLEntity, {
    required CLEntity? Function(CLEntity entity)? onGetParent,
    required List<CLEntity>? Function(CLEntity entity)? onGetChildren,
  }) itemBuilder;
  final Widget? Function(
    BuildContext context,
    List<GalleryGroupCLEntity<CLEntity>> galleryMap,
    GalleryGroupCLEntity<CLEntity> gallery,
  ) labelBuilder;
  final List<Widget> Function(
    BuildContext context,
    List<GalleryGroupCLEntity<CLEntity>> galleryMap,
  ) bannersBuilder;
  final Widget Function(
    BuildContext, {
    required GlobalKey<State<StatefulWidget>> parentKey,
  })? draggableMenuBuilder;

  @override
  Widget build(BuildContext context) {
    return RawCLEntityGalleryView(
      viewIdentifier: viewIdentifier,
      tabs: [
        LabelledEntityGroups(
            name: 'Media',
            galleryGroups: EntityGrouper(
                    method: GroupMethod.none,
                    columns: columns,
                    entities: incoming)
                .getGrouped)
      ],
      bannersBuilder: bannersBuilder,
      labelBuilder: labelBuilder,
      itemBuilder: (context, item) {
        return itemBuilder(
          context,
          item,
          onGetParent: null,
          onGetChildren: null,
        );
      },
      columns: columns,
      draggableMenuBuilder: draggableMenuBuilder,
    );
  }
}
