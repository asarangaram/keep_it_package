import 'package:app_loader/app_loader.dart';
import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/empty_state.dart';
import '../widgets/tags_as_folder.dart';

//For now, don't allow collectionID to be provided.
// as collection is not part of Tags. - Fix Me.
class TagsPage extends ConsumerStatefulWidget {
  const TagsPage({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TagsViewState();
}

class _TagsViewState extends ConsumerState<TagsPage> {
  bool isLoading = false;

  @override
  Widget build(BuildContext context) => LoadTags(
        //collectionID:  widget.collectionId ,
        buildOnData: (Tags tags) {
          final galleryGroups = <GalleryGroup>[];
          for (final rows in tags.entries.convertTo2D(3)) {
            galleryGroups.add(
              GalleryGroup(
                rows,
              ),
            );
          }
          return CLGalleryView(
            label: 'Tags',
            columns: 3,
            galleryMap: galleryGroups,
            emptyState: const EmptyState(),
            labelTextBuilder: (index) => galleryGroups[index].label ?? '',
            itemBuilder: (context, item, {required quickMenuScopeKey}) =>
                TagAsFolder(
              tag: item as Tag,
              quickMenuScopeKey: quickMenuScopeKey,
            ),
            tagPrefix: 'folder view tags "}',
            onPop: context.canPop()
                ? () {
                    context.pop();
                  }
                : null,
          );
        },
      );
}
