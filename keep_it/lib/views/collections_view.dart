import 'dart:async';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/from_store/from_store.dart';
import '../widgets/keepit_grid/keepit_grid.dart';

class CollectionsView extends ConsumerStatefulWidget {
  const CollectionsView({super.key, this.tagId});
  final int? tagId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CollectionsViewState();
}

class _CollectionsViewState extends ConsumerState<CollectionsView> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) => LoadCollections(
        tagId: widget.tagId,
        buildOnData: (collections) => Stack(
          children: [
            KeepItGrid(
              label: collections.tag?.label ?? 'Collections',
              entities: collections.entries,
              availableSuggestions: const [],
              itemSize: const Size(180, 300),
              onSelect: (BuildContext context, CollectionBase entity) async {
                unawaited(
                  context.push(
                    '/items/${entity.id}',
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
              onCreateNew: (context, ref) async {
                var res = false;
                setState(() {
                  isLoading = true;
                });
                if (mounted) {
                  res = await onPickFiles(context, ref);
                }
                if (mounted) {
                  setState(() {
                    isLoading = false;
                  });
                }
                return res;
              },
            ),
            if (isLoading)
              Container(
                color: Colors.grey.shade400.withAlpha(128),
                alignment: Alignment.center,
                child: const CircularProgressIndicator(),
              ),
          ],
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
      buildOnData: (Items items) {
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
