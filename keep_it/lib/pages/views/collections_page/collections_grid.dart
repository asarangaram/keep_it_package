import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'collections_grid_item.dart';
import 'paginated_grid.dart';

class CollectionsGrid extends ConsumerWidget {
  const CollectionsGrid({
    required this.quickMenuScopeKey,
    required this.collectionList,
    this.onTapCollection,
    this.onEditCollection,
    this.onDeleteCollection,
    super.key,
  });
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;
  final List<Collection> collectionList;
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
  Widget build(BuildContext context, WidgetRef ref) {
    if (collectionList.isEmpty) {
      throw Exception("This widget can't handle empty colections");
    }

    return LayoutBuilder(
      builder: (context, BoxConstraints constraints) {
        const childSize = Size(100, 120);
        final pageMatrix = computePageMatrix(
          pageSize: Size(
            constraints.maxWidth,
            constraints.maxHeight,
          ),
          itemSize: childSize,
        );

        final random = Random(42);
        final pages = (collectionList.length + (pageMatrix.totalCount - 1)) ~/
            pageMatrix.totalCount;
        return CLMatrix3D(
          pages: pages,
          rows: pageMatrix.height,
          columns: pageMatrix.width,
          itemCount: collectionList.length,
          itemBuilder: (context, index, layer) {
            return CollectionsGridItem(
              collection: collectionList[index],
              quickMenuScopeKey: quickMenuScopeKey,
              size: childSize,
              random: random,
              onTapCollection: onTapCollection,
              onEditCollection: onEditCollection,
              onDeleteCollection: onDeleteCollection,
            );
          },
        );
      },
    );
  }

  CLDimension computePageMatrix({
    required Size pageSize,
    required Size itemSize,
  }) {
    if (pageSize.width == double.infinity) {
      throw Exception("Width is unbounded, can't handle");
    }
    if (pageSize.height == double.infinity) {
      throw Exception("Width is unbounded, can't handle");
    }
    final itemsInRow = max(
      1,
      ((pageSize.width.nearest(itemSize.width)) / itemSize.width).floor(),
    );
    final itemsInColumn = max(
      1,
      ((pageSize.height.nearest(itemSize.height)) / itemSize.height).floor(),
    );

    return CLDimension(width: itemsInRow, height: itemsInColumn);
  }
}
