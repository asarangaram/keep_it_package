import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/ext_double.dart';
import '../utils/media/cl_dimension.dart';
import 'cl_matrix_2d.dart';

class CLMatrix3D extends StatefulWidget {
  const CLMatrix3D({
    required this.pages,
    required this.rows,
    required this.columns,
    required this.itemCount,
    required this.itemBuilder,
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

  final int? visibleItem;

  @override
  State<CLMatrix3D> createState() => _CLMatrix3DState();
}

class _CLMatrix3DState extends State<CLMatrix3D> {
  final PageController pageController = PageController();
  @override
  Widget build(BuildContext context) {
    if (widget.visibleItem != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final highLightPage =
            widget.visibleItem! ~/ (widget.rows * widget.columns);
        pageController.jumpToPage(highLightPage);
      });
    }
    return PageView.builder(
      controller: pageController,
      itemCount: widget.pages,
      itemBuilder: (context, pageNum) {
        final itemsInCurrentPage =
            ((pageNum * widget.rows * widget.columns) < widget.itemCount)
                ? widget.rows * widget.columns
                : widget.itemCount ~/ (widget.rows * widget.columns);

        return CLMatrix2D(
          itemCount: itemsInCurrentPage,
          itemBuilder: (context, index, layer) {
            if (pageNum * widget.rows * widget.columns + index >=
                widget.itemCount) {
              return Container();
            }
            return widget.itemBuilder(
              context,
              pageNum * widget.rows * widget.columns + index,
              layer,
            );
          },
          rows: widget.rows,
          columns: widget.columns,
          layers: widget.layers,
        );
      },
    );
  }
}

class CLMatrix3DAutoFit extends ConsumerWidget {
  const CLMatrix3DAutoFit({
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
        final pages =
            (itemCount + (pageMatrix.totalCount - 1)) ~/ pageMatrix.totalCount;

        return CLMatrix3D(
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
