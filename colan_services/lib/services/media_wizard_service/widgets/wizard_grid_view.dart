import 'package:flutter/material.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

import '../../../internal/entity_grid/gallery_view.dart';
import '../../context_menu_service/models/context_menu_items.dart';
import '../../gallery_view_service/widgets/view_modifier_builder.dart';

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
    return entities.isEmpty
        ? emptyWidget
        : ViewModifierBuilder(
            viewIdentifier: viewIdentifier,
            entities: entities,
            itemBuilder: itemBuilder,
            contextMenuOf: contextMenuBuilder,
            filtersDisabled: filterDisabled,
            onSelectionChanged: onSelectionChanged,
            bannersBuilder: bannersBuilder,
            builder: ({
              required incoming,
              required itemBuilder,
              required labelBuilder,
              required viewIdentifier,
              required bannersBuilder,
              required draggableMenuBuilder,
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
          );
  }
}
