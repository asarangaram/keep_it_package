import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/pages/views/collections_page/collections_grid_item.dart';
import 'package:store/store.dart';

class PaginatedGrid extends ConsumerWidget {
  const PaginatedGrid({
    required this.collections,
    required this.constraints,
    required this.quickMenuScopeKey,
    super.key,
  });
  final List<Collection> collections;
  final BoxConstraints constraints;
  final GlobalKey<State<StatefulWidget>> quickMenuScopeKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const childSize = Size(100, 120);
    final pageMatrix = computePageMatrix(
      pageSize: Size(
        constraints.maxWidth,
        constraints.maxHeight,
      ),
      itemSize: childSize,
    );

    final random = Random(42);
    final pages = (collections.length + (pageMatrix.totalCount - 1)) ~/
        pageMatrix.totalCount;
    return CLMatrix3D(
      pages: pages,
      rows: pageMatrix.height,
      columns: pageMatrix.width,
      itemCount: collections.length,
      itemBuilder: (context, index, layer) {
        return CollectionsGridItem(
          collection: collections[index],
          quickMenuScopeKey: quickMenuScopeKey,
          size: childSize,
          random: random,
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
