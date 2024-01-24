import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:keep_it/pages/views/collections_page/collections_list_item.dart';
import 'package:scroll_to_index/scroll_to_index.dart';
import 'package:store/store.dart';

import '../cl_blink.dart';

class CollectionsList extends ConsumerStatefulWidget {
  const CollectionsList({
    required this.collections,
    super.key,
    this.onSelection,
    this.selectionMask,
    this.onTapCollection,
    this.onEditCollection,
    this.onDeleteCollection,
  });

  final Collections collections;
  final void Function(int index)? onSelection;
  final List<bool>? selectionMask;
  final Future<bool?> Function(
    BuildContext context,
    Collection collection,
  )? onEditCollection;
  final Future<bool?> Function(
    BuildContext context,
    Collection collection,
  )? onDeleteCollection;
  final Future<bool?> Function(
    BuildContext context,
    Collection collection,
  )? onTapCollection;

  @override
  ConsumerState<CollectionsList> createState() => _CollectionsListState();
}

class _CollectionsListState extends ConsumerState<CollectionsList> {
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
    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      print('lastupdatedID ${widget.collections.lastupdatedID}');
      if (widget.collections.lastupdatedID != null) {
        controller.scrollToIndex(highLightIndex);
      } else {
        setState(() {
          highLightIndex = -1;
        });
      }
      print('highLightIndex $highLightIndex');
    }); */
    print('didChangeDependencies called');
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    final highLightIndex = widget.collections.entries
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

    return SizedBox.expand(
      child: ListView.builder(
        itemCount: widget.collections.entries.length,
        controller: controller,
        itemBuilder: (context, index) {
          final randomColor =
              Colors.primaries[random.nextInt(Colors.primaries.length)];
          return AutoScrollTag(
            key: ValueKey(index),
            controller: controller,
            index: index,
            highlightColor: Colors.black.withOpacity(0.1),
            child: Slidable(
              key: ValueKey('collectionslist_$index'),
              endActionPane: ActionPane(
                motion: const BehindMotion(),
                children: [
                  SlidableAction(
                    onPressed: (context) => widget.onEditCollection
                        ?.call(context, widget.collections.entries[index]),
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                  SlidableAction(
                    onPressed: (context) => widget.onDeleteCollection
                        ?.call(context, widget.collections.entries[index]),
                    icon: Icons.edit,
                    backgroundColor:
                        Theme.of(context).colorScheme.errorContainer,
                    foregroundColor:
                        Theme.of(context).colorScheme.onErrorContainer,
                    label: 'Delete',
                  ),
                ],
              ),
              child: CLHighlighted(
                isHighlighed: index == highLightIndex,
                child: CollectionsListItem(
                  widget.collections.entries[index],
                  isSelected: widget.selectionMask?[index],
                  backgroundColor: randomColor,
                  onTap: (widget.onSelection == null)
                      ? () => widget.onTapCollection
                          ?.call(context, widget.collections.entries[index])
                      : () => widget.onSelection!.call(index),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class CLHighlighted extends StatefulWidget {
  const CLHighlighted({
    required this.child,
    super.key,
    this.isHighlighed = false,
  });
  final Widget child;
  final bool isHighlighed;

  @override
  State<CLHighlighted> createState() => _CLHighlightedState();
}

class _CLHighlightedState extends State<CLHighlighted> {
  @override
  Widget build(BuildContext context) {
    if (!widget.isHighlighed) {
      return widget.child;
    }
    return CLBlink(
      blinkDuration: const Duration(milliseconds: 500),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            width: 2,
            color: Theme.of(context).highlightColor,
          ),
        ),
        child: widget.child,
      ),
    );
  }
}
