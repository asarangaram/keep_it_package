import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../basic_page_service/widgets/page_manager.dart';
import '../../models/entity_actions.dart';
import '../../views/context_menu.dart';
import 'collection_preview.dart';

class EntityPreview extends ConsumerWidget {
  const EntityPreview({
    required this.serverId,
    required this.item,
    required this.entities,
    required this.parentId,
    super.key,
  });

  final ViewerEntity item;
  final ViewerEntities entities;
  final int? parentId;
  final String serverId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = item as StoreEntity;

    final contextMenu =
        EntityActions.ofEntity(context, ref, entity, serverId: serverId);

    return KeepItContextMenu(
      onTap: () async {
        await PageManager.of(context).openEntity(entity, serverId: serverId);
        return true;
      },
      contextMenu: contextMenu,
      child: entity.isCollection
          ? CollectionPreview.preview(
              entity,
            )
          : MediaPreviewWithOverlays(
              media: entity,
            ),
    );
  }
}
