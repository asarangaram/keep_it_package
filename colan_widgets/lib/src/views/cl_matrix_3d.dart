import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/ext_double.dart';
import '../utils/media/cl_dimension.dart';
import 'cl_matrix_2d.dart';

class CLCustomGridAutoFit extends ConsumerWidget {
  const CLCustomGridAutoFit({
    required this.childSize,
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.layers = 1,
    this.visibleItem,
    this.maxPageDimension = const CLDimension(itemsInRow: 6, itemsInColumn: 6),
  });

  final Size childSize;

  final int itemCount;
  final Widget Function(BuildContext, int, int) itemBuilder;
  final int layers;
  final int? visibleItem;
  final CLDimension maxPageDimension;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LayoutBuilder(
      builder: (context, BoxConstraints constraints) {
        final pageMatrix = computePageMatrix(
          pageSize: Size(
            constraints.maxWidth,
            constraints.maxHeight,
          ),
          itemSize: childSize,
        );

        return CLCustomGrid(
          columns: pageMatrix.itemsInRow,
          itemCount: itemCount,
          layers: 2,
          itemBuilder: itemBuilder,
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
    final itemsInRow = min(
      maxPageDimension.itemsInRow,
      max(
        1,
        ((pageSize.width.nearest(itemSize.width)) / itemSize.width).floor(),
      ),
    );
    final itemsInColumn = min(
      maxPageDimension.itemsInColumn,
      max(
        1,
        ((pageSize.height.nearest(itemSize.height)) / itemSize.height).floor(),
      ),
    );

    return CLDimension(itemsInRow: itemsInRow, itemsInColumn: itemsInColumn);
  }
}
