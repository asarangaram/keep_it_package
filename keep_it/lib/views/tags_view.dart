import 'dart:async';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import '../widgets/dialogs.dart';
import '../widgets/from_store/from_store.dart';
import '../widgets/from_store/items_in_tag.dart';
import '../widgets/keepit_grid/keepit_grid.dart';

class TagsView extends ConsumerWidget {
  const TagsView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) => LoadTags(
        buildOnData: (tags) => KeepItGrid(
          label: 'Tags',
          entities: tags.entries,
          availableSuggestions: suggestedTags.where((element) {
            return !tags.entries.map((e) => e.label).contains(element.label);
          }).toList(),
          itemSize: const Size(100, 120),
          onSelect: (BuildContext context, CollectionBase entity) async {
            unawaited(
              context.push(
                '/collections/by_tag_id/${entity.id}',
              ),
            );
            return true;
          },
          onUpdate: (tags) => onUpdate(context, ref, tags),
          onDelete: (List<CollectionBase> selectedTags) async {
            ref
                .read(tagsProvider(null).notifier)
                .deleteTags(selectedTags.map(Tag.fromBase).toList());
            return true;
          },
          previewGenerator: (BuildContext context, CollectionBase tag) {
            return LoadItemsInTag(
              id: tag.id!,
              limit: 4,
              buildOnData: (clMediaList) {
                return CLMediaListPreview(
                  mediaList: clMediaList ?? [],
                  mediaCountInPreview:
                      const CLDimension(itemsInRow: 2, itemsInColumn: 2),
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
    List<CollectionBase> selectedTags,
  ) async {
    ref
        .read(tagsProvider(null).notifier)
        .upsertTags(selectedTags.map(Tag.fromBase).toList());
    return true;
  }
}
