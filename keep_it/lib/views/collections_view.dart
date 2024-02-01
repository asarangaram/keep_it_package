import 'dart:async';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/from_store/from_store.dart';
import '../widgets/keepit_grid/keepit_grid.dart';

class CollectionsView extends ConsumerWidget {
  const CollectionsView({super.key, this.tagId});
  final int? tagId;
  @override
  Widget build(BuildContext context, WidgetRef ref) => LoadCollections(
        tagId: tagId,
        buildOnData: (collections) => KeepItGrid(
          label: collections.tag?.label ?? 'Collections',
          entities: collections.entries,
          availableSuggestions: const [],
          itemSize: const Size(180, 300),
          onSelect: (BuildContext context, CollectionBase entity) async {
            unawaited(
              context.push(
                '/items/by_collection_id/${entity.id}',
              ),
            );
            return true;
          },
          onUpdate: (items) => onUpdate(context, ref, items),
          onDelete: (List<CollectionBase> selectedEntities) async {
            if (selectedEntities.length != 1) {
              throw Exception(
                "Unexected: Collections can't be added in bulk",
              );
            }
            for (final entity in selectedEntities) {
              await ref
                  .read(collectionsProvider(null).notifier)
                  .deleteCollection(Collection.fromBase(entity));
            }
            return true;
          },
          previewGenerator: (BuildContext context, CollectionBase entity) {
            if (entity.id == null) {
              throw Exception("Unexpected, id can't be null");
            }
            return PreviewGenerator(
              collectgionID: entity.id!,
            );
          },
          onCreateNew: onPickImages,
        ),
      );
  Future<bool> onUpdate(
    BuildContext context,
    WidgetRef ref,
    List<CollectionBase> selectedEntities,
  ) async {
    if (selectedEntities.length != 1) {
      throw Exception(
        "Unexected: Collections can't be added in bulk",
      );
    }
    for (final entity in selectedEntities) {
      await ref
          .read(collectionsProvider(null).notifier)
          .upsertCollection(Collection.fromBase(entity), null);
    }
    return true;
  }
}

class PreviewGenerator extends StatelessWidget {
  const PreviewGenerator({
    required this.collectgionID,
    super.key,
  });
  final int collectgionID;

  @override
  Widget build(BuildContext context) {
    return LoadItems(
      collectionID: collectgionID,
      buildOnData: (Items items, {required String docDir}) {
        return CLMediaListPreview(
          mediaList: items.entries,
          mediaCountInPreview:
              const CLDimension(itemsInRow: 2, itemsInColumn: 2),
          whenNopreview: CLText.veryLarge(
            items.collection.label.characters.first,
          ),
        );
      },
    );
  }
}
