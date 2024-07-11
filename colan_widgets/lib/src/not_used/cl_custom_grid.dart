/* import 'dart:math';

import 'package:flutter/material.dart';
import 'package:scroll_to_index/scroll_to_index.dart';

import '../extensions/ext_double.dart';
import '../models/cl_dimension.dart';

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

          final row = Row(
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
                      : itemBuilder(context, r * crossAxisCount + c, l),
                ),
            ],
          );
          return (controller == null)
              ? row
              : AutoScrollTag(
                  key: ValueKey('$r  $l'),
                  controller: controller!,
                  index: r * layers + l,
                  child: row,
                );
        },
      ),
    );
  }
}

//Why this can' be replaced by LayoutBuilder?
class ComputeSizeAndBuild extends StatefulWidget {
  const ComputeSizeAndBuild({
    required this.builder,
    this.builderWhenNoSize,
    super.key,
  });

  final Widget Function(BuildContext context, Size size) builder;
  final Widget Function(BuildContext context)? builderWhenNoSize;

  @override
  State<StatefulWidget> createState() => ComputeSizeAndBuildState();
}

class ComputeSizeAndBuildState extends State<ComputeSizeAndBuild> {
  final GlobalKey _containerKey = GlobalKey();
  Size? computedSize;

  @override
  void didChangeDependencies() {
    WidgetsBinding.instance.addPostFrameCallback(_computeSize);
    super.didChangeDependencies();
  }

  void _computeSize(_) {
    final renderBox =
        _containerKey.currentContext?.findRenderObject()! as RenderBox?;
    if (renderBox != null) {
      final widgetSize = renderBox.size;
      if (computedSize != widgetSize) {
        setState(() {
          computedSize = widgetSize;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      key: _containerKey,
      child: (computedSize == null)
          ? widget.builderWhenNoSize?.call(context)
          : widget.builder(context, computedSize!),
    );
  }
}
 */
