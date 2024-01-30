import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/from_store/from_store.dart';
import '../widgets/from_store/items_in_tag.dart';
import 'keepit_grid/keepit_grid.dart';

class CollectionsView extends ConsumerWidget {
  const CollectionsView({super.key, this.tagId});
  final int? tagId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => CLFullscreenBox(
        child: CLBackground(
          child: LoadCollections(
            tagId: tagId,
            buildOnData: (tags) => KeepItGrid(
              label: 'Collections',
              entities: tags.entries,
              availableSuggestions: const [],
              onSelect: (BuildContext context, CollectionBase entity) async {
                unawaited(
                  context.push(
                    '/collections/by_collection_id/${entity.id}',
                  ),
                );
                return true;
              },
              onUpdate: (List<CollectionBase> selectedEntities) {
                if (selectedEntities.length != 1) {
                  throw Exception(
                    "Unexected: Collections can't be added in bulk",
                  );
                }
                for (final entity in selectedEntities) {
                  ref
                      .read(collectionsProvider(null).notifier)
                      .upsertCollection(Collection.fromBase(entity), null);
                }
              },
              onDelete: (List<CollectionBase> selectedEntities) {
                if (selectedEntities.length != 1) {
                  throw Exception(
                    "Unexected: Collections can't be added in bulk",
                  );
                }
                for (final entity in selectedEntities) {
                  ref
                      .read(collectionsProvider(null).notifier)
                      .deleteCollection(Collection.fromBase(entity));
                }
              },
              previewGenerator: (BuildContext context, CollectionBase entity) {
                if (entity.id == null) {
                  throw Exception("Unexpected, id can't be null");
                }
                return LoadItems(
                  collectionID: entity.id!,
                  buildOnData: (Items items, {required String docDir}) {
                    final List<CLMedia> mediaList;
                    mediaList = items.entries.map(
                      (e) {
                        return e.toCLMedia(pathPrefix: docDir);
                      },
                    ).toList();
                    return CLMediaListPreview(
                      mediaList: mediaList,
                      mediaCountInPreview:
                          const CLDimension(itemsInRow: 2, itemsInColumn: 2),
                      whenNopreview: CLText.veryLarge(
                          items.collection.label.characters.first),
                    );
                  },
                );
              },
            ),
          ),
        ),
      );
}
