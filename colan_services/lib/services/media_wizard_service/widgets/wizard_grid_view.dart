import 'package:cl_entity_viewers/cl_entity_viewers.dart';

import 'package:flutter/material.dart';

import '../../context_menu_service/models/context_menu_items.dart';

import '../../gallery_view_service/widgets/when_empty.dart';

class CLGalleryView extends StatelessWidget {
  const CLGalleryView({
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
    required this.storeIdentity,
    this.filterDisabled = false,
    this.onSelectionChanged,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final String storeIdentity;
  final List<ViewerEntityMixin> entities;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function(BuildContext, ViewerEntityMixin) itemBuilder;
  final int columns;

  final Widget emptyWidget;
  final EntityContextMenu Function(BuildContext, List<ViewerEntityMixin>)
      contextMenuBuilder;
  final void Function(List<ViewerEntityMixin>)? onSelectionChanged;
  final bool filterDisabled;
  final bool viewableAsCollection;
  final List<Widget> Function(
    BuildContext context,
    List<ViewerEntityGroup<ViewerEntityMixin>> galleryMap,
  ) bannersBuilder;

  @override
  Widget build(BuildContext context) {
    return ViewModifierBuilder(
      tabIdentifier: TabIdentifier(view: viewIdentifier, tabId: 'Media'),
      incoming: entities,
      itemBuilder: itemBuilder,
      contextMenuBuilder: contextMenuBuilder,
      filtersDisabled: filterDisabled,
      onSelectionChanged: onSelectionChanged,
      bannersBuilder: bannersBuilder,
      whenEmpty: const WhenEmpty(),
    );
  }
}
