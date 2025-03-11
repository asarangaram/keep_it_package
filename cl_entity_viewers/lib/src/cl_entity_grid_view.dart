import 'package:flutter/material.dart';

import 'models/cl_entities.dart';
import 'models/gallery_group.dart';
import 'models/labeled_entity_groups.dart';
import 'models/media_grouper.dart';
import 'models/tab_identifier.dart';
import 'widgets/gallery_view.dart';

class CLEntityGridView extends StatelessWidget {
  CLEntityGridView(
      {required this.viewIdentifier,
      required this.numColumns,
      required List<CLEntity> entities,
      required this.itemBuilder,
      required this.labelBuilder,
      required this.headerWidgetsBuilder,
      required this.footerWidgetsBuilder,
      this.draggableMenuBuilder,
      super.key,
      GroupMethod groupMethod = GroupMethod.none})
      : tabs = {
          'singleTap': EntityGrouper(
              method: groupMethod, columns: numColumns, entities: entities)
        };
  const CLEntityGridView.tabs({
    required this.viewIdentifier,
    required this.numColumns,
    required this.tabs,
    required this.itemBuilder,
    required this.labelBuilder,
    required this.headerWidgetsBuilder,
    required this.footerWidgetsBuilder,
    this.draggableMenuBuilder,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final int numColumns;

  final Widget Function(BuildContext, CLEntity) itemBuilder;
  final Widget? Function(
    BuildContext context,
    List<GalleryGroupCLEntity<CLEntity>> galleryMap,
    GalleryGroupCLEntity<CLEntity> gallery,
  ) labelBuilder;
  final List<Widget> Function(
    BuildContext context,
    List<GalleryGroupCLEntity<CLEntity>> galleryMap,
  ) headerWidgetsBuilder;
  final List<Widget> Function(
    BuildContext,
    List<GalleryGroupCLEntity<CLEntity>>,
  ) footerWidgetsBuilder;
  final Widget Function(
    BuildContext, {
    required GlobalKey<State<StatefulWidget>> parentKey,
  })? draggableMenuBuilder;
  final Map<String, EntityGrouper> tabs;

  @override
  Widget build(BuildContext context) {
    return RawCLEntityGalleryView(
      viewIdentifier: viewIdentifier,
      tabs: [
        for (final entry in tabs.entries)
          LabelledEntityGroups(
              name: entry.key, galleryGroups: entry.value.getGrouped)
      ],
      headerWidgetsBuilder: headerWidgetsBuilder,
      footerWidgetsBuilder: footerWidgetsBuilder,
      labelBuilder: labelBuilder,
      itemBuilder: (context, item) {
        return itemBuilder(context, item);
      },
      columns: numColumns,
      draggableMenuBuilder: draggableMenuBuilder,
    );
  }
}
