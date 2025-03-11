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
    required this.numColumns,
    required this.entities,
    required this.itemBuilder,
    required this.labelBuilder,
    required this.bannersBuilder,
    this.draggableMenuBuilder,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final int numColumns;
  final List<CLEntity> entities;

  final Widget Function(BuildContext, CLEntity) itemBuilder;
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
                    columns: numColumns,
                    entities: entities)
                .getGrouped)
      ],
      bannersBuilder: bannersBuilder,
      labelBuilder: labelBuilder,
      itemBuilder: (context, item) {
        return itemBuilder(context, item);
      },
      columns: numColumns,
      draggableMenuBuilder: draggableMenuBuilder,
    );
  }
}
