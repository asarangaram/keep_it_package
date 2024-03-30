import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../widgets/empty_state.dart';
import '../widgets/folders_and_files/tags_as_folder.dart';

class TagsPage extends ConsumerStatefulWidget {
  const TagsPage({super.key, this.collectionId});
  final int? collectionId;
  @override
  ConsumerState<ConsumerStatefulWidget> createState() => TagsPageState();
}

class TagsPageState extends ConsumerState<TagsPage> {
  bool isLoading = false;
  bool excludeEmpty = true;

  @override
  Widget build(BuildContext context) => GetCollection(
        id: widget.collectionId,
        buildOnData: (collection) {
          return GetTagMultiple(
            excludeEmpty: excludeEmpty,
            collectionId: widget.collectionId,
            buildOnData: (tags) {
              final tagPrefix =
                  'FolderView Tags CollectionId: ${widget.collectionId} '
                  ' excludeEmpty: $excludeEmpty';
              final galleryGroups = <GalleryGroup<Tag>>[];
              for (final rows in tags.convertTo2D(3)) {
                galleryGroups.add(
                  GalleryGroup(
                    rows,
                  ),
                );
              }
              return CLSimpleGalleryView(
                key: ValueKey(tagPrefix),
                title: collection?.label ?? 'Tags',
                columns: 3,
                galleryMap: galleryGroups,
                emptyState: const EmptyState(),
                itemBuilder: (context, item, {required quickMenuScopeKey}) =>
                    TagAsFolder(
                  tag: item,
                  quickMenuScopeKey: quickMenuScopeKey,
                ),
                tagPrefix: tagPrefix,
                onRefresh: () async {
                  ref.invalidate(dbManagerProvider);
                },
              );
            },
          );
        },
      );
}
