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

  bool excludeEmpty = true;

  @override
  Widget build(BuildContext context) => GetTag(
        id: widget.tagId,
        buildOnData: (tag) {
          return GetCollectionMultiple(
            excludeEmpty: excludeEmpty,
            tagId: widget.tagId,
            buildOnData: (collections) {
              final tagPrefix = 'FolderView Collections tagId: ${widget.tagId}'
                  ' excludeEmpty: $excludeEmpty';
              final galleryGroups = <GalleryGroup<Collection>>[];
              for (final rows in collections.convertTo2D(3)) {
                galleryGroups.add(
                  GalleryGroup(
                    rows,
                  ),
                );
              }
              return CLSimpleGalleryView(
                key: ValueKey(tagPrefix),
                title: tag?.label ?? 'Collections',
                columns: 3,
                galleryMap: galleryGroups,
                emptyState: const EmptyState(),
                itemBuilder: (context, item, {required quickMenuScopeKey}) =>
                    CollectionAsFolder(
                  collection: item,
                  quickMenuScopeKey: quickMenuScopeKey,
                ),
                tagPrefix: tagPrefix,
                onPickFiles: (widget.tagId != null)
                    ? null
                    : () async {
                        await onPickFiles(
                          context,
                          ref,
                        );
                      },
                onRefresh: () async {
                  ref.invalidate(dbManagerProvider);
                },
                onPop: context.canPop()
                    ? () {
                        context.pop();
                      }
                    : null,
              );
            },
          );
        },
      );
}
