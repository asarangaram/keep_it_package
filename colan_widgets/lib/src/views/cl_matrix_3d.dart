import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/ext_double.dart';
import '../utils/media/cl_dimension.dart';
import 'cl_matrix_2d.dart';

class CLMatrix3D extends StatelessWidget {
  const CLMatrix3D({
    required this.pages,
    required this.rows,
    required this.columns,
    required this.itemCount,
    required this.itemBuilder,
    required this.pageController,
    super.key,
    this.layers = 1,
    this.visibleItem,
  });

  final int pages;
  final int rows;
  final int columns;
  final int itemCount;
  final int layers;
  final Widget Function(BuildContext context, int index, int layer) itemBuilder;
  final PageController pageController;
  final int? visibleItem;

  @override
  Widget build(BuildContext context) {
    if (visibleItem != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final highLightPage = visibleItem! ~/ (rows * columns);
        pageController.jumpToPage(highLightPage);
      });
    }
    return PageView.builder(
      controller: pageController,
      itemCount: pages,
      itemBuilder: (context, pageNum) {
        final itemsInCurrentPage = ((pageNum * rows * columns) < itemCount)
            ? rows * columns
            : itemCount ~/ (rows * columns);

        return CLMatrix2D(
          itemCount: itemsInCurrentPage,
          itemBuilder: (context, index, layer) {
            if (pageNum * rows * columns + index >= itemCount) {
              return Container();
            }
            return itemBuilder(
              context,
              pageNum * rows * columns + index,
              layer,
            );
          },
          rows: rows,
          columns: columns,
          layers: layers,
        );
      },
    );
  }
}

class CLMatrix3DAutoFit extends ConsumerWidget {
  const CLMatrix3DAutoFit({
    required this.childSize,
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    super.key,
    this.layers = 1,
    this.visibleItem,
    this.maxPageDimension = const CLDimension(itemsInRow: 6, itemsInColumn: 6),
  });

  final Size childSize;
  final PageController controller;
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
        final pages =
            (itemCount + (pageMatrix.totalCount - 1)) ~/ pageMatrix.totalCount;

        return CLMatrix3D(
          pageController: controller,
          pages: pages,
          rows: pageMatrix.itemsInColumn,
          columns: pageMatrix.itemsInRow,
          itemCount: itemCount,
          layers: 2,
          itemBuilder: itemBuilder,
          visibleItem: visibleItem,
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
