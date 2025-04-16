import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../draggable_menu/providers/menu_position.dart';
import '../../../entity/models/cl_context_menu.dart';
import '../../../entity/models/viewer_entity_mixin.dart';
import '../../../gallery_grid_view/models/tab_identifier.dart';
import '../../../selection/providers/selector.dart';
import '../../../selection/widgets/selection_control.dart';

class ViewModifierBuilder extends StatelessWidget {
  const ViewModifierBuilder(
      {required this.tabIdentifier,
      required this.incoming,
      required this.bannersBuilder,
      required this.itemBuilder,
      required this.contextMenuBuilder,
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
      contextMenuBuilder;
  final void Function(List<ViewerEntityMixin>)? onSelectionChanged;
  final bool filtersDisabled;
  final List<Widget> Function(
    BuildContext context,
    List<ViewerEntityGroup<ViewerEntityMixin>> galleryMap,
  ) bannersBuilder;

  final Widget whenEmpty;
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        selectorProvider.overrideWith((ref) => SelectorNotifier(incoming)),
        menuPositionNotifierProvider
            .overrideWith((ref) => MenuPositionNotifier()),
      ],
      child: SelectionContol(
        tabIdentifier: tabIdentifier,
        itemBuilder: itemBuilder,
        contextMenuBuilder: contextMenuBuilder,
        onSelectionChanged: onSelectionChanged,
        filtersDisabled: filtersDisabled,
        whenEmpty: whenEmpty,
      ),
    );
  }
}
