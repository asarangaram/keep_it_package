import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_services/services/gallery_view_service/widgets/on_swipe.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../media_view_service/media_view_service.dart';
import 'gallery_view_service.dart';
import 'widgets/when_error.dart';

class EntityViewer extends ConsumerWidget {
  const EntityViewer({
    required this.parentIdentifier,
    required this.storeIdentity,
    required this.id,
    super.key,
  });
  final String parentIdentifier;
  final String storeIdentity;
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
    return AppTheme(
      child: OnSwipe(
        child: GetEntity(
          id: id,
          storeIdentity: storeIdentity,
          errorBuilder: errorBuilder,
          loadingBuilder: () =>
              Scaffold(body: CLLoader.widget(debugMessage: 'GetEntity')),
          builder: (entity) {
            if (entity?.isCollection ?? true) {
              return GetEntities(
                parentId: id,
                storeIdentity: storeIdentity,
                errorBuilder: errorBuilder,
                loadingBuilder: () => Scaffold(
                  body: CLLoader.widget(debugMessage: 'GetEntities'),
                ),
                builder: (children) {
                  return GalleryViewService(
                    viewIdentifier: viewIdentifier,
                    storeIdentity: storeIdentity,
                    parent: entity,
                    children: children,
                  );
                },
              );
            } else {
              return GetEntities(
                parentId: entity!.parentId,
                storeIdentity: storeIdentity,
                errorBuilder: errorBuilder,
                loadingBuilder: () => Scaffold(
                  body: CLLoader.widget(debugMessage: 'GetEntities'),
                ),
                builder: (entities) {
                  return MediaViewService(
                    parentIdentifier: parentIdentifier,
                    entities: entities,
                    currentIndex: entities.indexWhere((e) => e.id == entity.id),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}
