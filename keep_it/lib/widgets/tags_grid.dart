import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'from_store/items_in_tag.dart';

import 'wrap_standard_quick_menu.dart';

class TagsGrid extends ConsumerWidget {
  const TagsGrid({
    required this.quickMenuScopeKey,
    required this.tags,
    this.onTapTag,
    this.onEditTag,
    this.onDeleteTag,
    super.key,
  });
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;
  final Tags tags;
  final Future<bool?> Function(
    BuildContext context,
    Tag tag,
  )? onEditTag;
  final Future<bool?> Function(
    BuildContext context,
    Tag tag,
  )? onDeleteTag;
  final Future<bool?> Function(
    BuildContext context,
    Tag tag,
  )? onTapTag;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final highLightIndex = tags.lastupdatedID == null
        ? -1
        : tags.entries.indexWhere((e) => e.id == tags.lastupdatedID);

    return CLMatrix3DAutoFit(
      childSize: const Size(100, 120),
      itemCount: tags.entries.length,
      layers: 2,
      visibleItem: highLightIndex <= -1 ? null : highLightIndex,
      itemBuilder: (context, index, layer) {
        final tag = tags.entries[index];
        if (layer == 0) {
          return CLHighlighted(
            isHighlighed: index == highLightIndex,
            child: WrapStandardQuickMenu(
              quickMenuScopeKey: quickMenuScopeKey,
              onEdit: () async => onEditTag!.call(
                context,
                tag,
              ),
              onDelete: () async => onDeleteTag!.call(
                context,
                tag,
              ),
              onTap: () async => onTapTag!.call(
                context,
                tag,
              ),
              child: LoadItemsInTag(
                id: tag.id,
                limit: 4,
                buildOnData: (clMediaList) {
                  return CLMediaListPreview(
                    mediaList: clMediaList ?? [],
                    mediaCountInPreview:
                        const CLDimension(itemsInRow: 2, itemsInColumn: 2),
                    whenNopreview: CLText.veryLarge(tag.label.characters.first),
                  );
                },
              ),
            ),
          );
        } else if (layer == 1) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              tags.entries[index].label,
              maxLines: 2,
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          );
        }
        throw Exception('Incorrect layer');
      },
    );
  }
}
