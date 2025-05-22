import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../basic_page_service/widgets/page_manager.dart';

import '../../models/entity_actions.dart';

import 'collection_preview.dart';
import '../../views/context_menu.dart';

class EntityPreview extends ConsumerWidget {
  const EntityPreview({
    required this.viewIdentifier,
    required this.item,
    required this.entities,
    required this.parentId,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final ViewerEntityMixin item;
  final List<ViewerEntityMixin> entities;
  final int? parentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = item as StoreEntity;

    final contextMenu = EntityActions.ofEntity(
      context,
      ref,
      entity,
    );

    return KeepItContextMenu(
      viewIdentifier: viewIdentifier,
      onTap: () async {
        await PageManager.of(context).openEntity(
          entity,
          parentIdentifier: viewIdentifier.parentID,
        );
        return true;
      },
      contextMenu: contextMenu,
      child: entity.isCollection
          ? CollectionPreview.preview(
              entity,
              viewIdentifier: viewIdentifier,
            )
          : MediaPreviewWithOverlays(
              media: entity,
              parentIdentifier: viewIdentifier.toString(),
            ),
    );
  }
}
