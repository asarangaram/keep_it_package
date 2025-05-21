import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/menu_position.dart';
import '../models/cl_context_menu.dart';
import '../../common/models/viewer_entity_mixin.dart';
import '../models/tab_identifier.dart';
import '../providers/selector.dart';
import 'selection_control.dart';

class CLGalleryGridView extends StatelessWidget {
  const CLGalleryGridView(
      {required this.viewIdentifier,
      required this.incoming,
      required this.itemBuilder,
      required this.contextMenuBuilder,
      required this.filtersDisabled,
      required this.onSelectionChanged,
      super.key,
      required this.whenEmpty});

  final ViewIdentifier viewIdentifier;
  final List<ViewerEntityMixin> incoming;
  final Widget Function(
      BuildContext, ViewerEntityMixin, List<ViewerEntityMixin>) itemBuilder;
  final CLContextMenu Function(BuildContext, List<ViewerEntityMixin>)?
      contextMenuBuilder;
  final void Function(List<ViewerEntityMixin>)? onSelectionChanged;
  final bool filtersDisabled;
  final Widget whenEmpty;

  @override
  Widget build(BuildContext context) {
    return CLGalleryGridView0(
      key: ValueKey("CLGalleryGridView $viewIdentifier"),
      viewIdentifier: viewIdentifier,
      incoming: incoming,
      itemBuilder: itemBuilder,
      contextMenuBuilder: contextMenuBuilder,
      onSelectionChanged: onSelectionChanged,
      filtersDisabled: filtersDisabled,
      whenEmpty: whenEmpty,
    );
  }
}

class CLGalleryGridView0 extends StatelessWidget {
  const CLGalleryGridView0(
      {required this.viewIdentifier,
      required this.incoming,
      required this.itemBuilder,
      required this.contextMenuBuilder,
      required this.filtersDisabled,
      required this.onSelectionChanged,
      super.key,
      required this.whenEmpty});

  final ViewIdentifier viewIdentifier;
  final List<ViewerEntityMixin> incoming;
  final Widget Function(
      BuildContext, ViewerEntityMixin, List<ViewerEntityMixin>) itemBuilder;
  final CLContextMenu Function(BuildContext, List<ViewerEntityMixin>)?
      contextMenuBuilder;
  final void Function(List<ViewerEntityMixin>)? onSelectionChanged;
  final bool filtersDisabled;
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
        viewIdentifier: viewIdentifier,
        itemBuilder: itemBuilder,
        contextMenuBuilder: contextMenuBuilder,
        onSelectionChanged: onSelectionChanged,
        filtersDisabled: filtersDisabled,
        whenEmpty: whenEmpty,
      ),
    );
  }
}
