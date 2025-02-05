import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart' show CLEntity, GalleryGroupCLEntity;

import '../../services/context_menu_service/models/context_menu_items.dart';
import '../../services/gallery_view_service/widgets/view_modifier_builder.dart';
import 'widgets/gallery_view.dart';

class CLEntityGalleryView extends StatelessWidget {
  const CLEntityGalleryView({
    required this.viewIdentifier,
    required this.entities,
    required this.loadingBuilder,
    required this.errorBuilder,
    required this.itemBuilder,
    required this.bannersBuilder,
    required this.columns,
    required this.emptyWidget,
    required this.contextMenuBuilder,
    required this.viewableAsCollection,
    this.filterDisabled = false,
    this.onSelectionChanged,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final List<CLEntity> entities;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function(
    BuildContext,
    CLEntity, {
    required CLEntity? Function(CLEntity entity)? onGetParent,
    required List<CLEntity>? Function(CLEntity entity)? onGetChildren,
  }) itemBuilder;
  final int columns;

  final Widget emptyWidget;
  final CLContextMenu Function(BuildContext, List<CLEntity>) contextMenuBuilder;
  final void Function(List<CLEntity>)? onSelectionChanged;
  final bool filterDisabled;
  final bool viewableAsCollection;
  final List<Widget> Function(
    BuildContext context,
    List<GalleryGroupCLEntity<CLEntity>> galleryMap,
  ) bannersBuilder;

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      switchOutCurve: Curves.easeInOut,
      transitionBuilder: (
        Widget child,
        Animation<double> animation,
      ) =>
          FadeTransition(opacity: animation, child: child),
      child: entities.isEmpty
          ? emptyWidget
          : ViewModifierBuilder(
              viewIdentifier: viewIdentifier,
              entities: entities,
              loadingBuilder: loadingBuilder,
              errorBuilder: errorBuilder,
              itemBuilder: itemBuilder,
              columns: columns,
              contextMenuOf: contextMenuBuilder,
              filtersOff: filterDisabled,
              onSelectionChanged: onSelectionChanged,
              bannersBuilder: bannersBuilder,
              builder: ({
                required bannersBuilder,
                required columns,
                required draggableMenuBuilder,
                required errorBuilder,
                required incoming,
                required itemBuilder,
                required labelBuilder,
                required loadingBuilder,
                required viewIdentifier,
              }) {
                /* return MediaViewService1.pageView(
                  media: incoming.map((e) => e as CLMedia).toList(),
                  parentIdentifier: viewIdentifier.toString(),
                  initialMediaIndex: 0,
                  errorBuilder: errorBuilder,
                  loadingBuilder: () => CLLoader.widget(
                    debugMessage: 'MediaViewService.pageView',
                  ),
                ); */
                return EntityGridView(
                  viewIdentifier: viewIdentifier,
                  errorBuilder: errorBuilder,
                  loadingBuilder: loadingBuilder,
                  incoming: incoming,
                  columns: columns,
                  viewableAsCollection: viewableAsCollection,
                  itemBuilder: itemBuilder,
                  labelBuilder: labelBuilder,
                  bannersBuilder: bannersBuilder,
                  draggableMenuBuilder: draggableMenuBuilder,
                );
              },
            ),
    );
  }
}

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
