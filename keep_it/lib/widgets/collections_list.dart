import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';

import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:store/store.dart';

import 'collections_list_item.dart';

class TagsList extends ConsumerStatefulWidget {
  const TagsList({
    required this.collections,
    super.key,
    this.onSelection,
    this.selectionMask,
    this.onTapTag,
    this.onEditTag,
    this.onDeleteTag,
  });

  final Tags collections;
  final void Function(int index)? onSelection;
  final List<bool>? selectionMask;
  final Future<bool?> Function(
    BuildContext context,
    Tag collection,
  )? onEditTag;
  final Future<bool?> Function(
    BuildContext context,
    Tag collection,
  )? onDeleteTag;
  final Future<bool?> Function(
    BuildContext context,
    Tag collection,
  )? onTapTag;

  @override
  ConsumerState<TagsList> createState() => _TagsListState();
}

class _TagsListState extends ConsumerState<TagsList> {
  late AutoScrollController controller;

  @override
  void initState() {
    controller = AutoScrollController(
      viewportBoundaryGetter: () =>
          Rect.fromLTRB(0, 0, 0, MediaQuery.of(context).padding.bottom),
      axis: Axis.vertical,
    );
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final highLightIndex = widget.collections.lastupdatedID == null
        ? -1
        : widget.collections.entries
            .indexWhere((e) => e.id == widget.collections.lastupdatedID);
    if (highLightIndex > -1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        controller.scrollToIndex(highLightIndex);
      });
    }
    /*  */
    if (widget.selectionMask != null) {
      if (widget.selectionMask!.length != widget.collections.entries.length) {
        throw Exception('Selection is setup incorrectly');
      }
    }
    if (widget.collections.entries.isEmpty) {
      throw Exception("This widget can't handle empty colections");
    }

    final random = Random(42);

    return CLMatrix2D(
      itemCount: widget.collections.entries.length,
      controller: controller,
      columns: 1,
      itemHeight: 200,
      itemBuilder: (context, index, l) {
        final randomColor =
            Colors.primaries[random.nextInt(Colors.primaries.length)];
        return Slidable(
          key: ValueKey('collectionslist_$index'),
          endActionPane: ActionPane(
            motion: const BehindMotion(),
            children: [
              SlidableAction(
                onPressed: (context) => widget.onEditTag
                    ?.call(context, widget.collections.entries[index]),
                icon: Icons.edit,
                label: 'Edit',
              ),
              SlidableAction(
                onPressed: (context) => widget.onDeleteTag
                    ?.call(context, widget.collections.entries[index]),
                icon: Icons.edit,
                backgroundColor: Theme.of(context).colorScheme.errorContainer,
                foregroundColor: Theme.of(context).colorScheme.onErrorContainer,
                label: 'Delete',
              ),
            ],
          ),
          child: CLHighlighted(
            isHighlighed: index == highLightIndex,
            child: TagsListItem(
              widget.collections.entries[index],
              isSelected: widget.selectionMask?[index],
              backgroundColor: randomColor,
              onTap: (widget.onSelection == null)
                  ? () => widget.onTapTag
                      ?.call(context, widget.collections.entries[index])
                  : () => widget.onSelection!.call(index),
            ),
          ),
        );
      },
    );
  }
}
