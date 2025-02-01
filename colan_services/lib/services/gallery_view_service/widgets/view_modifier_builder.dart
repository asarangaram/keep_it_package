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
    required this.loadingBuilder,
    required this.errorBuilder,
    required this.itemBuilder,
    required this.numColumns,
    required this.contextMenuOf,
    required this.filtersOff,
    required this.onSelectionChanged,
    required this.builder,
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
  final int numColumns;

  final CLContextMenu Function(BuildContext, List<CLEntity>)? contextMenuOf;
  final void Function(List<CLEntity>)? onSelectionChanged;
  final bool filtersOff;

  final Widget Function({
    required ViewIdentifier viewIdentifier,
    required int columns,
    required List<CLEntity> incoming,
    required Widget Function(Object, StackTrace) errorBuilder,
    required Widget Function() loadingBuilder,
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
    return SelectionControl(
      viewIdentifier: viewIdentifier,
      contextMenuOf: contextMenuOf,
      onSelectionChanged: onSelectionChanged,
      incoming: entities,
      itemBuilder: itemBuilder,
      labelBuilder: (context, galleryMap, gallery) {
        return gallery.label == null
            ? null
            : CLText.large(
                gallery.label!,
                textAlign: TextAlign.start,
              );
      },
      bannersBuilder: (context, galleryMap) {
        return [];
      },
      builder: ({
        required items,
        required itemBuilder,
        required labelBuilder,
        required bannersBuilder,
        draggableMenuBuilder,
      }) {
        return GetFilterredMedia(
          viewIdentifier: viewIdentifier,
          errorBuilder: errorBuilder,
          loadingBuilder: loadingBuilder,
          incoming: entities,
          bannersBuilder: bannersBuilder,
          disabled: filtersOff,
          builder: (
            List<CLEntity> filterred, {
            required List<Widget> Function(
              BuildContext,
              List<GalleryGroupCLEntity<CLEntity>>,
            ) bannersBuilder,
          }) {
            return builder(
              viewIdentifier: viewIdentifier,
              errorBuilder: errorBuilder,
              loadingBuilder: loadingBuilder,
              incoming: filterred,
              columns: numColumns,
              itemBuilder: itemBuilder,
              labelBuilder: labelBuilder,
              bannersBuilder: bannersBuilder,
              draggableMenuBuilder: draggableMenuBuilder,
            );
          },
        );
      },
    );
  }
}
