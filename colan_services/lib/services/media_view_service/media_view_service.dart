import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../internal/fullscreen_layout.dart';
import '../basic_page_service/widgets/page_manager.dart';

import '../gallery_view_service/providers/active_collection.dart';
import '../gallery_view_service/widgets/when_error.dart';

import 'media_view_service1.dart';

class MediaViewService extends ConsumerWidget {
  const MediaViewService({
    required this.id,
    required this.parentId,
    required this.parentIdentifier,
    required this.storeIdentity,
    super.key,
  });
  final String storeIdentity;
  final int? parentId;
  final int id;
  final String parentIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Widget errorBuilder(Object e, StackTrace st) => WhenError(
          errorMessage: e.toString(),
        );
    final parentId = ref.watch(activeCollectionProvider)?.id;
    final viewIdentifier = ViewIdentifier(
      parentID: parentIdentifier,
      viewId: parentId.toString(),
    );
    if (parentId == 0) {
      GetEntity(
        storeIdentity: storeIdentity,
        id: id,
        errorBuilder: errorBuilder,
        loadingBuilder: () => CLLoader.widget(
          debugMessage: 'MediaViewService',
        ),
        builder: (entity) {
          if (entity == null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              PageManager.of(context).pop();
            });
          }
          return MediaViewService0(
            media: [if (entity != null) entity],
            parentIdentifier: viewIdentifier.toString(),
            initialMediaIndex: 0,
            errorBuilder: errorBuilder,
            loadingBuilder: () => CLLoader.widget(
              debugMessage: 'MediaViewService.pageView',
            ),
          );
        },
      );
    }
    return AppTheme(
      child: FullscreenLayout(
        child: GetEntities(
          parentId: parentId,
          storeIdentity: storeIdentity,
          loadingBuilder: () => CLLoader.widget(
            debugMessage: 'GetAvailableMediaByCollectionId',
          ),
          errorBuilder: errorBuilder,
          builder: (entities) {
            if (entities.isEmpty) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                PageManager.of(context).pop();
              });
            }

            //FIXME Filter
            return MediaViewService0(
              media: entities.map((e) => e).toList(),
              parentIdentifier: viewIdentifier.toString(),
              initialMediaIndex: entities.indexWhere((e) => e.id == id),
              errorBuilder: errorBuilder,
              loadingBuilder: () => CLLoader.widget(
                debugMessage: 'MediaViewService.pageView',
              ),
            );
          },
        ),
      ),
    );
  }
}
