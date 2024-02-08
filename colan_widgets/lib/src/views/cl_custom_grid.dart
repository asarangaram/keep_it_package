import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import 'compute_size_and_build.dart';

class CLCustomGrid extends StatelessWidget {
  const CLCustomGrid({
    required this.itemBuilder,
    required this.itemCount,
    required int crossAxisCount,
    required this.layers,
    required this.controller,
    super.key,
    // ignore: prefer_initializing_formals
  })  : crossAxisCount = crossAxisCount,
        childSize = null,
        maxPageDimension = const CLDimension(itemsInRow: 6, itemsInColumn: 6);
  const CLCustomGrid.fit({
    required Size childSize,
    required this.itemCount,
    required this.itemBuilder,
    required this.controller,
    required this.layers,
    super.key,
    this.maxPageDimension = const CLDimension(itemsInRow: 6, itemsInColumn: 6),
  })  : crossAxisCount = null,
        // ignore: prefer_initializing_formals
        childSize = childSize;
  final Size? childSize;
  final int? crossAxisCount;

  final Widget Function(BuildContext context, int index, int layer) itemBuilder;
  final int itemCount;

  final int layers;
  final AutoScrollController? controller;
  final CLDimension maxPageDimension;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, BoxConstraints constraints) {
        final int crossAxisCount;
        if (this.crossAxisCount == null) {
          assert(childSize != null, "childSize can't be null.");
          final pageMatrix = computePageMatrix(
            pageSize: Size(
              constraints.maxWidth,
              constraints.maxHeight,
            ),
            itemSize: childSize!,
          );
          crossAxisCount = pageMatrix.itemsInRow;
        } else {
          crossAxisCount = this.crossAxisCount!;
        }

        final vCount = (itemCount + crossAxisCount - 1) ~/ crossAxisCount;

        return _CLCustomGrid(
          numRows: vCount,
          layers: layers,
          crossAxisCount: crossAxisCount,
          itemCount: itemCount,
          controller: controller,
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

class _CLCustomGrid extends StatelessWidget {
  const _CLCustomGrid({
    required this.numRows,
    required this.layers,
    required this.crossAxisCount,
    required this.itemCount,
    required this.controller,
    required this.itemBuilder,
  });

  final int numRows;
  final int layers;
  final int crossAxisCount;
  final int itemCount;
  final AutoScrollController? controller;
  final Widget Function(BuildContext context, int index, int layer) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return ComputeSizeAndBuild(
      builder: (context, size) => ListView.builder(
        physics: const ClampingScrollPhysics(),
        controller: controller,
        itemCount: numRows * layers,
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
              for (var c = 0; c < crossAxisCount; c++)
                SizedBox(
                  width: size.width / crossAxisCount,
                  child: ((r * crossAxisCount + c) >= itemCount)
                      ? null
                      : (controller == null)
                          ? itemBuilder(context, r * crossAxisCount + c, l)
                          : AutoScrollTag(
                              key: ValueKey('$r $c $l'),
                              controller: controller!,
                              index: r * layers + l,
                              highlightColor: Colors.black.withOpacity(0.1),
                              child: itemBuilder(
                                context,
                                r * crossAxisCount + c,
                                l,
                              ),
                            ),
                ),
            ],
          );
        },
      ),
    );
  }
}
