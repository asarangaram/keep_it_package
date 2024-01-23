import 'dart:ffi';
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
    required this.collectionList,
    super.key,
    this.onSelection,
    this.selectionMask,
    this.onTapCollection,
    this.onEditCollection,
    this.onDeleteCollection,
  });

  final List<Collection> collectionList;
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
  Widget build(BuildContext context) {
    /* WidgetsBinding.instance.addPostFrameCallback((_) {
      controller.scrollToIndex(0);
    }); */
    if (widget.selectionMask != null) {
      if (widget.selectionMask!.length != widget.collectionList.length) {
        throw Exception('Selection is setup incorrectly');
      }
    }
    if (widget.collectionList.isEmpty) {
      throw Exception("This widget can't handle empty colections");
    }

    final random = Random(42);

    return SizedBox.expand(
      child: ListView.builder(
        itemCount: widget.collectionList.length,
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
                        ?.call(context, widget.collectionList[index]),
                    icon: Icons.edit,
                    label: 'Edit',
                  ),
                  SlidableAction(
                    onPressed: (context) => widget.onDeleteCollection
                        ?.call(context, widget.collectionList[index]),
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
                isHighlighed: index == 0,
                child: CollectionsListItem(
                  widget.collectionList[index],
                  isSelected: widget.selectionMask?[index],
                  backgroundColor: randomColor,
                  onTap: (widget.onSelection == null)
                      ? () => widget.onTapCollection
                          ?.call(context, widget.collectionList[index])
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
  late bool timeout;
  @override
  void initState() {
    timeout = false;
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          timeout = true;
        });
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isHighlighed || timeout) {
      return widget.child;
    }
    return CLBlink(
      blinkDuration: const Duration(milliseconds: 400),
      child: widget.child,
    );
  }
}
