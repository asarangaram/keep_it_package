import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:content_store/content_store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../basic_page_service/widgets/page_manager.dart';
import '../../context_menu_service/models/context_menu_items.dart';
import '../../context_menu_service/widgets/pull_down_context_menu.dart';
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

    return switch (item.isCollection) {
      true => Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Flexible(
                child: GetEntities(
                  storeIdentity: (item as StoreEntity).store.store.identity,
                  parentId: (item as StoreEntity).id,
                  loadingBuilder: GreyShimmer.new,
                  errorBuilder: (e, st) => const BrokenImage(),
                  builder: (children) {
                    return CLBasicContextMenu(
                      viewIdentifier: viewIdentifier,
                      onTap: () async {
                        ref
                            .read(
                              activeCollectionProvider.notifier,
                            )
                            .state = entity;
                        return null;
                      },
                      contextMenu: EntityContextMenu.ofCollection(
                        context,
                        ref,
                        collection: entity,
                      ),
                      child: CollectionView.preview(
                        entity,
                        viewIdentifier: viewIdentifier,
                        containingMedia: children.map((e) => e).toList(),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        entity.data.label!.capitalizeFirstLetter(),
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  EntityMetaData(
                    contextMenu: EntityContextMenu.ofCollection(
                      context,
                      ref,
                      collection: entity,
                    ),
                    child: const Icon(LucideIcons.ellipsis),
                  ),
                ],
              ),
            ],
          ),
        ),
      false => GetCollection(
          storeIdentity: (item as StoreEntity).store.store.identity,
          id: (item as StoreEntity).parentId,
          loadingBuilder: GreyShimmer.new,
          errorBuilder: (e, st) => const BrokenImage(),
          builder: (parent) {
            if (parent == null) {
              throw Exception(
                'Failed to get collection of media ${(item as StoreEntity).id}',
              );
            }
            return CLBasicContextMenu(
              viewIdentifier: viewIdentifier,
              onTap: () async {
                await PageManager.of(context).openMedia(
                  entity.data.id!,
                  parentId: entity.data.parentId,
                  parentIdentifier: viewIdentifier.parentID,
                );
                return true;
              },
              contextMenu: EntityContextMenu.ofMedia(
                context,
                ref,
                media: entity,
                parentCollection: parent,
              ),
              child: MediaPreviewWithOverlays(
                media: entity,
                parentIdentifier: viewIdentifier.toString(),
              ),
            );
          },
        ),
    };
  }
}
