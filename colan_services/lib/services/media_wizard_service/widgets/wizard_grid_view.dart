import 'package:cl_entity_viewers/cl_entity_viewers.dart';

import 'package:flutter/material.dart';

import '../../entity_viewer_service/models/entity_actions.dart';
import '../../entity_viewer_service/widgets/when_empty.dart';

class CLGalleryView extends StatelessWidget {
  const CLGalleryView({
    required this.viewIdentifier,
    required this.entities,
    required this.loadingBuilder,
    required this.errorBuilder,
    required this.itemBuilder,
    required this.columns,
    required this.emptyWidget,
    required this.contextMenuBuilder,
    required this.viewableAsCollection,
    this.filterDisabled = false,
    this.onSelectionChanged,
    super.key,
  });
  final ViewIdentifier viewIdentifier;

  final List<ViewerEntityMixin> entities;
  final Widget Function() loadingBuilder;
  final Widget Function(Object, StackTrace) errorBuilder;
  final Widget Function(
    BuildContext,
    ViewerEntityMixin,
    List<ViewerEntityMixin>,
  ) itemBuilder;
  final int columns;

  final Widget emptyWidget;
  final EntityActions Function(BuildContext, List<ViewerEntityMixin>)
      contextMenuBuilder;
  final void Function(List<ViewerEntityMixin>)? onSelectionChanged;
  final bool filterDisabled;
  final bool viewableAsCollection;

  @override
  Widget build(BuildContext context) {
    return CLEntitiesGridView(
      viewIdentifier: viewIdentifier,
      incoming: entities,
      itemBuilder: itemBuilder,
      contextMenuBuilder: contextMenuBuilder,
      filtersDisabled: filterDisabled,
      onSelectionChanged: onSelectionChanged,
      whenEmpty: const WhenEmpty(),
    );
  }
}
