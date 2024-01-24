import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'collection_preview.dart';

import 'wrap_standard_quick_menu.dart';

class CollectionsGrid extends ConsumerStatefulWidget {
  const CollectionsGrid({
    required this.quickMenuScopeKey,
    required this.collections,
    this.onTapCollection,
    this.onEditCollection,
    this.onDeleteCollection,
    super.key,
  });
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;
  final Collections collections;
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
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _CollectionsGridState();
}

class _CollectionsGridState extends ConsumerState<CollectionsGrid> {
  final PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    final random = Random(42);
    final highLightIndex = widget.collections.lastupdatedID == null
        ? -1
        : widget.collections.entries
            .indexWhere((e) => e.id == widget.collections.lastupdatedID);

    return CLMatrix3DAutoFit(
      pageController: pageController,
      childSize: const Size(100, 120),
      itemCount: widget.collections.entries.length,
      layers: 2,
      visibleItem: highLightIndex <= -1 ? null : highLightIndex,
      itemBuilder: (context, index, layer) {
        final randomColor =
            Colors.primaries[random.nextInt(Colors.primaries.length)];
        final collection = widget.collections.entries[index];
        if (layer == 0) {
          return CLHighlighted(
            isHighlighed: index == highLightIndex,
            child: WrapStandardQuickMenu(
              quickMenuScopeKey: widget.quickMenuScopeKey,
              onEdit: () async => widget.onEditCollection!.call(
                context,
                collection,
              ),
              onDelete: () async => widget.onDeleteCollection!.call(
                context,
                collection,
              ),
              onTap: () async => widget.onTapCollection!.call(
                context,
                collection,
              ),
              child: CLGridItemSquare(backgroundColor: randomColor),
            ),
          );
        } else if (layer == 1) {
          return Text(
            widget.collections.entries[index].label,
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
