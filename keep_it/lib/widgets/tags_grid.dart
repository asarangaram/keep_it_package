import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'from_store/cluster_count.dart';
import 'tag_preview.dart';
import 'wrap_standard_quick_menu.dart';

class TagsGrid extends ConsumerStatefulWidget {
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
  ConsumerState<ConsumerStatefulWidget> createState() => _TagsGridState();
}

class _TagsGridState extends ConsumerState<TagsGrid> {
  final PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    final highLightIndex = widget.tags.lastupdatedID == null
        ? -1
        : widget.tags.entries
            .indexWhere((e) => e.id == widget.tags.lastupdatedID);

    return CLMatrix3DAutoFit(
      controller: pageController,
      childSize: const Size(100, 120),
      itemCount: widget.tags.entries.length,
      layers: 2,
      visibleItem: highLightIndex <= -1 ? null : highLightIndex,
      itemBuilder: (context, index, layer) {
        final tag = widget.tags.entries[index];
        if (layer == 0) {
          return CLHighlighted(
            isHighlighed: index == highLightIndex,
            child: WrapStandardQuickMenu(
              quickMenuScopeKey: widget.quickMenuScopeKey,
              onEdit: () async => widget.onEditTag!.call(
                context,
                tag,
              ),
              onDelete: () async => widget.onDeleteTag!.call(
                context,
                tag,
              ),
              onTap: () async => widget.onTapTag!.call(
                context,
                tag,
              ),
              child: ClusterCount(
                tagId: tag.id,
                buildOnData: (count) => CLGridItemSquare(
                  backgroundColor: Theme.of(context).colorScheme.background,
                  child: Stack(
                    children: [
                      TagPreview(
                        tag: tag,
                      ),
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: CLText.small(
                          count.toString(),
                          textAlign: TextAlign.end,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        } else if (layer == 1) {
          return Text(
            widget.tags.entries[index].label,
            maxLines: 2,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          );
        }
        throw Exception('Incorrect layer');
      },
    );
  }
}
