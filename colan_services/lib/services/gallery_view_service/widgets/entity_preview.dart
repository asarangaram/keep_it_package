import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../basic_page_service/widgets/page_manager.dart';
import '../../media_view_service/preview/collection_preview.dart';

import '../../media_view_service/preview/media_preview.dart';
import '../models/entity_actions.dart';
import '../providers/active_collection.dart';
import 'context_menu.dart';

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

    final contextMenu = EntityActions.ofEntity(
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

    return KeepItContextMenu(
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
            parentId: ref.read(activeCollectionProvider)?.id,
            parentIdentifier:
                viewIdentifier.parentID, // FIXME: Is this correct?
          );
        }
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
