import 'dart:async';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/keepit_grid/cl_folder_view.dart';

class CollectionsPage extends ConsumerStatefulWidget {
  const CollectionsPage({super.key, this.tagId});
  final int? tagId;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CollectionsViewState();
}

class _CollectionsViewState extends ConsumerState<CollectionsPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) => LoadCollections(
        tagId: widget.tagId,
        buildOnData: (collections) => Stack(
          children: [
            FolderView(
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
                    "Unexected: Collections can't be deleted in bulk",
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
                  collectionID: entity.id!,
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
      final collectionId = await ref
          .read(collectionsProvider(null).notifier)
          .upsertCollection(Collection.fromBase(entity), null);
      // ignore: unused_local_variable
      final items = ref.refresh(itemsProvider(collectionId));
    }
    return true;
  }
}

class PreviewGenerator extends StatelessWidget {
  const PreviewGenerator({
    required this.collectionID,
    super.key,
  });
  final int collectionID;

  @override
  Widget build(BuildContext context) {
    return LoadItems(
      collectionID: collectionID,
      buildOnData: (Items items) {
        return CLMediaCollage.byMatrixSize(
          items.entries,
          hCount: 2,
          vCount: 2,
          itemBuilder: (context, index) => CLMediaPreview(
            media: items.entries[index],
          ),
          whenNopreview: CLText.veryLarge(
            items.collection.label.characters.first,
          ),
        );
      },
    );
  }
}
