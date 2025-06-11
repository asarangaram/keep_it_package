import 'package:cl_entity_viewers/cl_entity_viewers.dart';

import 'package:colan_services/services/entity_viewer_service/views/keep_it_error_view.dart';
import 'package:colan_services/services/entity_viewer_service/views/keep_it_grid_view.dart';
import 'package:colan_services/services/entity_viewer_service/views/keep_it_load_view.dart';
import 'package:colan_services/services/entity_viewer_service/views/keep_it_page_view.dart';
import 'package:content_store/content_store.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

    return const KeepItLoadView();

    /* return GetContent(
      id: id,
      loadingBuilder: KeepItLoadView.new,
      errorBuilder: (e, st) => KeepItErrorView(e: e, st: st),
      builder: (entity, children, siblings) {
        if (entity?.isCollection ?? true) {
          return KeepItGridView(
            viewIdentifier: viewIdentifier,
            parent: entity,
            children: children,
          );
        } else {
          return KeepItPageView(
            viewIdentifier: viewIdentifier,
            entity: entity!,
            siblings: siblings,
          );
        }
      },
    ); */
  }
}
