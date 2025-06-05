import 'package:cl_entity_viewers/cl_entity_viewers.dart';

import 'package:colan_services/services/entity_viewer_service/views/entity_page_view.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'views/entity_grid_view.dart';

import 'widgets/on_swipe.dart';
import 'widgets/when_error.dart';

class EntityViewerService extends ConsumerWidget {
  const EntityViewerService({
    required this.parentIdentifier,
    required this.id,
    super.key,
  });
  final String parentIdentifier;

  final int? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parentId = id;
    final viewIdentifier = ViewIdentifier(
      parentID: parentIdentifier,
      viewId: parentId.toString(),
    );
    Widget errorBuilder(Object e, StackTrace st) => Scaffold(
          body: WhenError(
            errorMessage: e.toString(),
          ),
        );
    return OnSwipe(
      child: GetEntity(
        id: id,
        errorBuilder: errorBuilder,
        loadingBuilder: () =>
            Scaffold(body: CLLoader.widget(debugMessage: 'GetEntity')),
        builder: (entity) {
          if (entity?.isCollection ?? true) {
            return GetEntities(
              parentId: id,
              errorBuilder: errorBuilder,
              loadingBuilder: () => Scaffold(
                body: CLLoader.widget(debugMessage: 'GetEntities'),
              ),
              builder: (children) {
                return CLEntitiesGridViewScope(
                  child: EntityGridView(
                    viewIdentifier: viewIdentifier,
                    parent: entity,
                    children: children,
                  ),
                );
              },
            );
          } else {
            return GetEntities(
              parentId: entity!.parentId,
              errorBuilder: errorBuilder,
              loadingBuilder: () => Scaffold(
                body: CLLoader.widget(debugMessage: 'GetEntities'),
              ),
              builder: (siblings) {
                return CLEntitiesPageViewScope(
                  siblings: siblings,
                  currentEntity: entity,
                  child: EntityPageView(
                    parentIdentifier: parentIdentifier,
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
