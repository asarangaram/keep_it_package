import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../basic_page_service/widgets/page_manager.dart';
import '../../context_menu_service/models/context_menu_items.dart';
import '../../context_menu_service/widgets/shad_context_menu.dart';
import '../../gallery_view_service/providers/active_collection.dart';
import 'collection_view.dart';
import 'media_preview_service.dart';

class EntityPreview extends ConsumerWidget {
  const EntityPreview({
    required this.viewIdentifier,
    required this.item,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final ViewerEntityMixin item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entity = item as StoreEntity;

    final contextMenu = EntityContextMenu.ofEntity(
      context,
      ref,
      entity,
    );
    /* final label = Row(
      children: [
        Expanded(
          child: Center(
            child: Text(
              entity.data.label?.capitalizeFirstLetter() ?? 'Unnamed',
              style: const TextStyle(fontSize: 14),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        EntityMetaData(
          contextMenu: contextMenu,
          child: const Icon(LucideIcons.ellipsis),
        ),
      ],
    ); */

    return CLBasicContextMenu(
      viewIdentifier: viewIdentifier,
      onTap: () async {
        if (entity.isCollection) {
          ref
              .read(
                activeCollectionProvider.notifier,
              )
              .state = entity;
        } else {
          await PageManager.of(context).openMedia(
            entity.data.id!,
            parentId: entity.data.parentId,
            parentIdentifier: viewIdentifier.parentID,
          );
        }
        return true;
      },
      contextMenu: contextMenu,
      child: entity.isCollection
          ? CollectionView.preview(
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
