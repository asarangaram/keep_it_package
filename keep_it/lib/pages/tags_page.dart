import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/tags/dialogs.dart';

import '../widgets/tags/tags_folder_view.dart';

class TagsPage extends ConsumerWidget {
  const TagsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => LoadTags(
        buildOnData: (tags) => TagsFolderView(
          label: 'Tags',
          entities: tags.entries,
          availableSuggestions: suggestedTags.where((element) {
            return !tags.entries.map((e) => e.label).contains(element.label);
          }).toList(),
          itemSize: const Size(100, 120),
          onSelect: (BuildContext context, Tag entity) async {
            unawaited(
              context.push(
                '/collections/${entity.id}',
              ),
            );
            return true;
          },
          onUpdate: (tags) => onUpdate(context, ref, tags),
          onDelete: (List<Tag> selectedTags) async {
            ref.read(tagsProvider(null).notifier).deleteTags(selectedTags);
            return true;
          },
          previewGenerator: (BuildContext context, Tag tag) {
            return LoadItemsInTag(
              id: tag.id!,
              limit: 4,
              buildOnData: (clMediaList) {
                return CLMediaCollage.byMatrixSize(
                  clMediaList ?? [],
                  hCount: 2,
                  vCount: 2,
                  itemBuilder: (context, index) => CLMediaPreview(
                    media: clMediaList![index],
                  ),
                  whenNopreview: CLText.veryLarge(tag.label.characters.first),
                );
              },
            );
          },
          onCreateNew: (BuildContext context, WidgetRef ref) async {
            final tag = await KeepItDialogs.upsert(context);
            if (tag != null && context.mounted) {
              return onUpdate(context, ref, [tag]);
            }
            return false;
          },
        ),
      );
  Future<bool> onUpdate(
    BuildContext context,
    WidgetRef ref,
    List<Tag> selectedTags,
  ) async {
    ref.read(tagsProvider(null).notifier).upsertTags(selectedTags);
    return true;
  }
}
