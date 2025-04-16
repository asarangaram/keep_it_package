import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

import '../../../entity/models/cl_context_menu.dart';
import '../../../entity/models/viewer_entity_mixin.dart';
import '../../../gallery_grid_view/models/tab_identifier.dart';
import '../../../selection/widgets/selection_control.dart';

class ViewModifierBuilder extends StatelessWidget {
  const ViewModifierBuilder(
      {required this.tabIdentifier,
      required this.incoming,
      required this.bannersBuilder,
      required this.itemBuilder,
      required this.contextMenuOf,
      required this.filtersDisabled,
      required this.onSelectionChanged,
      super.key,
      required this.whenEmpty});

  final TabIdentifier tabIdentifier;
  final List<ViewerEntityMixin> incoming;

  final Widget Function(
    BuildContext,
    ViewerEntityMixin,
  ) itemBuilder;

  final CLContextMenu Function(BuildContext, List<ViewerEntityMixin>)?
      contextMenuOf;
  final void Function(List<ViewerEntityMixin>)? onSelectionChanged;
  final bool filtersDisabled;
  final List<Widget> Function(
    BuildContext context,
    List<ViewerEntityGroup<ViewerEntityMixin>> galleryMap,
  ) bannersBuilder;

  final Widget whenEmpty;
  @override
  Widget build(BuildContext context) {
    return SelectionControl(
      tabIdentifier: tabIdentifier,
      contextMenuOf: contextMenuOf,
      onSelectionChanged: onSelectionChanged,
      incoming: incoming,
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
      filtersDisabled: filtersDisabled,
      whenEmpty: whenEmpty,
    );
  }
}
