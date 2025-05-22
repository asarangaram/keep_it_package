import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../basic_page_service/widgets/page_manager.dart';

import '../models/entity_actions.dart';

import 'collection_preview.dart';
import 'context_menu.dart';

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
          await PageManager.of(context).openCollection(
            entity,
            parentIdentifier: viewIdentifier.parentID,
          );
        } else {
          // Setup provider, it may be good idea to have a single function
          // to avoid extra notification
          final supportedEntities =
              entities /* .where((e) => e.mediaType == CLMediaType.image).toList() */;
          ref.read(mediaViewerUIStateProvider.notifier).entities =
              supportedEntities;
          ref.read(mediaViewerUIStateProvider.notifier).currIndex =
              supportedEntities.indexWhere((e) => e.id == entity.data.id!);

          await PageManager.of(context).openMedia(
            entity.data.id!,
            parentId: parentId,
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
