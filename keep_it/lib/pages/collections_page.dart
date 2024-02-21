import 'dart:async';

import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/collection/collection_folder_view.dart';
import 'timeline_page.dart';

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
        buildOnData: (collections) {
          final galleryGroups = <GalleryGroup>[];
          for (final rows in collections.entries.convertTo2D(3)) {
            galleryGroups.add(
              GalleryGroup(
                rows,
              ),
            );
          }
          return CLGalleryView(
            label: collections.tag?.label ?? 'Collections',
            columns: 3,
            galleryMap: galleryGroups,
            emptyState: const EmptyState(),
            labelTextBuilder: (index) => galleryGroups[index].label ?? '',
            itemBuilder: (context, item) {
              final collection = item as Collection;
              return GestureDetector(
                onTap: () {},
                child: PreviewGenerator(
                  collectionID: collection.id!,
                ),
              );
            },
            tagPrefix: 'timeline ${collections.tag?.id ?? "all"}',
            onPickFiles: () async {
              await onPickFiles(
                context,
                ref,
              );
            },
            onPop: context.canPop()
                ? () {
                    context.pop();
                  }
                : null,
          );
        },
      );
  Future<bool> onUpdate(
    BuildContext context,
    WidgetRef ref,
    List<Collection> selectedEntities,
  ) async {
    if (selectedEntities.length != 1) {
      throw Exception(
        "Unexected: Collections can't be added in bulk",
      );
    }
    for (final entity in selectedEntities) {
      final collectionId = await ref
          .read(collectionsProvider(null).notifier)
          .upsertCollection(entity, null);
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
