import 'dart:math';

import 'package:flutter/material.dart';

import '../extensions/ext_double.dart';
import '../utils/media/cl_dimension.dart';
import 'cl_matrix_2d_fixed.dart';
import 'compute_size_and_build.dart';

class CLMatrix2DScrollable extends StatelessWidget {
  const CLMatrix2DScrollable({
    required this.itemBuilder,
    required this.hCount,
    required this.vCount,
    required this.layers,
    required this.itemCount,
    this.leadingRow,
    this.trailingRow,
    super.key,
    this.controller,
    this.itemHeight,
    this.borderSide = BorderSide.none,
    this.decoration,
  });

  final Widget Function(BuildContext context, int r, int c, int l) itemBuilder;
  final Widget? leadingRow;
  final Widget? trailingRow;

  final int hCount;
  final int vCount;
  final int layers;
  final ScrollController? controller;
  final double? itemHeight;
  final BorderSide borderSide;
  final BoxDecoration? decoration;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ComputeSizeAndBuild(
      builder: (context, size) {
        /* print(
          ' Available Size $size, hCount = $hCount, vCount = $vCount, '
          'lCount= $lCount',
        ); */
        return ListView.builder(
          itemCount: vCount * layers,
          /* prototypeItem: SizedBox(
            height: min((size.width / hCount) * 1.4, size.height),
          ), */
          itemBuilder: (context, index) {
            final r = index ~/ layers;
            final l = index - r * layers;

            return Row(
              crossAxisAlignment: l == 0
                  ? CrossAxisAlignment.end
                  : l == (layers - 1)
                      ? CrossAxisAlignment.start
                      : CrossAxisAlignment.center,
              children: [
                for (var c = 0; c < hCount; c++)
                  if ((r * hCount + c) >= itemCount)
                    const Center()
                  else
                    Flexible(
                      child: Container(
                        margin: EdgeInsets.symmetric(
                          horizontal: (borderSide != BorderSide.none ||
                                  decoration != null)
                              ? 2
                              : 0,
                        ),
                        width: size.width / hCount,
                        decoration: BoxDecoration(
                          border: Border(
                            left: borderSide,
                            right: borderSide,
                            top: (l == 0) ? borderSide : BorderSide.none,
                            bottom: (l == (layers - 1))
                                ? borderSide
                                : BorderSide.none,
                          ),
                        ),
                        child: DecoratedBox(
                          decoration: decoration ?? const BoxDecoration(),
                          child: Padding(
                            padding: EdgeInsets.only(
                              top: l == 0 ? 2 : 0,
                              left: 2,
                              right: 2,
                              bottom: l == (layers - 1) ? 2 : 0,
                            ),
                            child: itemBuilder(context, r, c, l),
                          ),
                        ),
                      ),
                    ), //
              ],
            );
          },
        );
      },
    );
  }
}

class CLMatrix2DScrollable2 extends StatelessWidget {
  const CLMatrix2DScrollable2({
    required this.itemBuilder,
    required this.hCount,
    required this.itemCount,
    super.key,
  });

  final Widget Function(BuildContext context, int index) itemBuilder;
  final int hCount;
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: (itemCount + hCount - 1) ~/ hCount,
      itemBuilder: (context, r) {
        return Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            for (var c = 0; c < hCount; c++)
              if ((r * hCount + c) >= itemCount)
                Expanded(child: Container())
              else
                Expanded(
                  child: itemBuilder(context, r * hCount + c),
                ), //
          ],
        );
      },
    );
  }
}

class CLMatrix2DAutoFit extends StatelessWidget {
  const CLMatrix2DAutoFit({
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
  final Widget Function(BuildContext, int) itemBuilder;
  final int layers;
  final int? visibleItem;
  final CLDimension maxPageDimension;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, BoxConstraints constraints) {
        final pageMatrix = computePageMatrix(
          pageSize: Size(
            constraints.maxWidth,
            constraints.maxHeight,
          ),
          itemSize: childSize,
        );

        return Matrix2DNew.scrollable(
          hCount: pageMatrix.itemsInRow,
          itemCount: itemCount,
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
