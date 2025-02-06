import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

import '../../../internal/entity_grid/widgets/selection_control/selection_control.dart';
import '../../context_menu_service/models/context_menu_items.dart';

class ViewModifierBuilder extends StatelessWidget {
  const ViewModifierBuilder({
    required this.viewIdentifier,
    required this.entities,
    required this.bannersBuilder,
    required this.itemBuilder,
    required this.contextMenuOf,
    required this.filtersDisabled,
    required this.onSelectionChanged,
    required this.builder,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final List<CLEntity> entities;

  final Widget Function(
    BuildContext,
    CLEntity, {
    required CLEntity? Function(CLEntity entity)? onGetParent,
    required List<CLEntity>? Function(CLEntity entity)? onGetChildren,
  }) itemBuilder;

  final CLContextMenu Function(BuildContext, List<CLEntity>)? contextMenuOf;
  final void Function(List<CLEntity>)? onSelectionChanged;
  final bool filtersDisabled;
  final List<Widget> Function(
    BuildContext context,
    List<GalleryGroupCLEntity<CLEntity>> galleryMap,
  ) bannersBuilder;
  final Widget Function({
    required ViewIdentifier viewIdentifier,
    required List<CLEntity> incoming,
    required Widget Function(
      BuildContext,
      CLEntity, {
      required CLEntity? Function(CLEntity entity)? onGetParent,
      required List<CLEntity>? Function(CLEntity entity)? onGetChildren,
    }) itemBuilder,
    required Widget? Function(
      BuildContext context,
      List<GalleryGroupCLEntity<CLEntity>> galleryMap,
      GalleryGroupCLEntity<CLEntity> gallery,
    ) labelBuilder,
    required List<Widget> Function(
      BuildContext context,
      List<GalleryGroupCLEntity<CLEntity>> galleryMap,
    ) bannersBuilder,
    required Widget Function(
      BuildContext, {
      required GlobalKey<State<StatefulWidget>> parentKey,
    })? draggableMenuBuilder,
  }) builder;

  @override
  Widget build(BuildContext context) {
    return GetSortedEntity(
      entities: entities,
      builder: (sorted) {
        return SelectionControl(
          viewIdentifier: viewIdentifier,
          contextMenuOf: contextMenuOf,
          onSelectionChanged: onSelectionChanged,
          incoming: sorted,
          itemBuilder: itemBuilder,
          labelBuilder: (context, galleryMap, gallery) {
            return gallery.label == null
                ? null
                : CLText.large(
                    gallery.label!,
                    textAlign: TextAlign.start,
                  );
          },
          bannersBuilder: bannersBuilder,
          builder: ({
            required items,
            required itemBuilder,
            required labelBuilder,
            required bannersBuilder,
            draggableMenuBuilder,
          }) {
            return GetFilterredMedia(
              viewIdentifier: viewIdentifier,
              incoming: entities,
              bannersBuilder: bannersBuilder,
              disabled: filtersDisabled,
              builder: (
                List<CLEntity> filterred, {
                required List<Widget> Function(
                  BuildContext,
                  List<GalleryGroupCLEntity<CLEntity>>,
                ) bannersBuilder,
              }) {
                return builder(
                  viewIdentifier: viewIdentifier,
                  incoming: filterred,
                  itemBuilder: itemBuilder,
                  labelBuilder: labelBuilder,
                  bannersBuilder: bannersBuilder,
                  draggableMenuBuilder: draggableMenuBuilder,
                );
              },
            );
          },
        );
      },
    );
  }
}
