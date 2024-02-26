import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/empty_state.dart';
import '../widgets/folders_and_files/collection_as_folder.dart';

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
  Widget build(BuildContext context) => GetCollectionsByTagId(
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
            itemBuilder: (context, item, {required quickMenuScopeKey}) =>
                CollectionAsFolder(
              collection: item as Collection,
              quickMenuScopeKey: quickMenuScopeKey,
            ),
            tagPrefix: 'timeline ${collections.tag?.id ?? "all"}',
            isScrollablePositionedList: false,
            onPickFiles: () async {
              await onPickFiles(
                context,
                ref,
              );
            },
            onRefresh: () async {
              // TODO (anandas):
            },
            onPop: context.canPop()
                ? () {
                    context.pop();
                  }
                : null,
          );
        },
      );
}
