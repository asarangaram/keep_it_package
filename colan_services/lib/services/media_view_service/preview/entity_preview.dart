import 'package:content_store/content_store.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
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
    required this.theStore,
    super.key,
    this.onGetParent,
    this.onGetChildren,
  });
  final ViewIdentifier viewIdentifier;
  final CLEntity item;
  final CLEntity? Function(CLEntity entity)? onGetParent;
  final List<CLEntity>? Function(CLEntity entity)? onGetChildren;
  final StoreUpdater theStore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final parent = onGetParent?.call(item);
    final children = onGetChildren?.call(item);
    switch (item.isCollection) {
      case true: // What if empty collection?
        if (children == null) {
          throw Exception(
            'Failed to get media list of collection ${(item as CLMedia).id}',
          );
        }
      case false:
        if (parent == null) {
          throw Exception(
            'Failed to get collection of media ${(item as CLMedia).id}',
          );
        }
    }
    final c = item as CLMedia;
    final m = item as CLMedia;
    return switch (item.isCollection) {
      true => Padding(
          padding: const EdgeInsets.all(8),
          child: Column(
            children: [
              Flexible(
                child: CLBasicContextMenu(
                  viewIdentifier: viewIdentifier,
                  onTap: () async {
                    ref
                        .read(
                          activeCollectionProvider.notifier,
                        )
                        .state = c.id;
                    return null;
                  },
                  contextMenu: CLContextMenu.ofCollection(
                    context,
                    ref,
                    collection: c,
                    hasOnlineService: false,
                    theStore: theStore,
                  ),
                  child: CollectionView.preview(
                    c,
                    viewIdentifier: viewIdentifier,
                    containingMedia:
                        children!.map((e) => e as CLMedia).toList(),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Center(
                      child: Text(
                        c.label!.capitalizeFirstLetter(),
                        style: const TextStyle(fontSize: 14),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                  EntityMetaData(
                    contextMenu: CLContextMenu.ofCollection(
                      context,
                      ref,
                      collection: c,
                      hasOnlineService: false,
                      theStore: theStore,
                    ),
                    child: const Icon(LucideIcons.ellipsis),
                  ),
                ],
              ),
            ],
          ),
        ),
      false => CLBasicContextMenu(
          viewIdentifier: viewIdentifier,
          onTap: () async {
            await PageManager.of(context).openMedia(
              m.id!,
              collectionId: m.parentId,
              parentIdentifier: viewIdentifier.parentID,
            );
            return true;
          },
          contextMenu: CLContextMenu.ofMedia(
            context,
            ref,
            media: m,
            parentCollection: parent! as CLMedia,
            hasOnlineService: false,
            theStore: theStore,
          ),
          child: MediaPreviewWithOverlays(
            media: m,
            parentIdentifier: viewIdentifier.toString(),
          ),
        ),
    };
  }
}
