import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart' show CLEntity, GalleryGroupCLEntity;

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
        tabs /* columns */, {
        required CLEntity? Function(CLEntity entity)? onGetParent,
        required List<CLEntity>? Function(CLEntity entity)? onGetChildren,
      }) {
        return RawCLEntityGalleryView(
          viewIdentifier: viewIdentifier,
          tabs: tabs,
          bannersBuilder: bannersBuilder,
          labelBuilder: labelBuilder,
          itemBuilder: (context, item) {
            return itemBuilder(
              context,
              item,
              onGetParent: onGetParent,
              onGetChildren: onGetChildren,
            );
          },
          columns: columns,
          draggableMenuBuilder: draggableMenuBuilder,
        );
      },
    );
  }
}
