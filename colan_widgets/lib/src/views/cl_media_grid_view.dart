import 'dart:math';

import 'package:flutter/material.dart';

import '../extensions/ext_double.dart';
import '../models/cl_media.dart';
import '../utils/media/cl_dimension.dart';
import 'cl_decorate_square.dart';
import 'cl_matrix_2d_fixed.dart';
import 'cl_media_view.dart';

class CLMediaGridView extends StatelessWidget {
  const CLMediaGridView._({
    required this.mediaList,
    required this.canScroll,
    required this.keepAspectRatio,
    required this.maxPageDimension,
    this.hCount,
    this.vCount,
    this.childSize,
    super.key,
  });
  factory CLMediaGridView.byMatrixSize(
    List<CLMedia> mediaList, {
    required int hCount,
    int? vCount,
    Key? key,
    bool? keepAspectRatio,
    CLDimension? maxPageDimension,
  }) {
    return CLMediaGridView._(
      mediaList: mediaList,
      key: key,
      hCount: hCount,
      vCount: vCount,
      keepAspectRatio: keepAspectRatio ?? false,
      canScroll: vCount == null,
      maxPageDimension: maxPageDimension ??
          const CLDimension(itemsInRow: 6, itemsInColumn: 6),
    );
  }
  factory CLMediaGridView.byChildSize(
    List<CLMedia> mediaList, {
    required Size childSize,
    Key? key,
    bool? keepAspectRatio,
    bool canScroll = false,
    CLDimension? maxPageDimension,
  }) {
    return CLMediaGridView._(
      mediaList: mediaList,
      childSize: childSize,
      key: key,
      keepAspectRatio: keepAspectRatio ?? false,
      canScroll: canScroll,
      maxPageDimension: maxPageDimension ??
          const CLDimension(itemsInRow: 6, itemsInColumn: 6),
    );
  }

  final List<CLMedia> mediaList;
  final int? hCount;
  final int? vCount;
  final bool keepAspectRatio;
  final Size? childSize;
  final bool canScroll;
  final CLDimension maxPageDimension;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final int x;
        final int? y;
        if (childSize == null) {
          x = hCount!;
          y = vCount;
        } else {
          final pageMatrix = computePageMatrix(
            pageSize: Size(
              constraints.maxWidth,
              constraints.maxHeight,
            ),
            itemSize: childSize!,
          );
          x = pageMatrix.itemsInRow;
          y = canScroll ? null : pageMatrix.itemsInColumn;
        }
        return switch (y) {
          null => Matrix2DNew.scrollable(
              itemCount: mediaList.length,
              hCount: x,
              itemBuilder: itemBuilder,
            ),
          _ => Matrix2DNew(
              itemCount: mediaList.length,
              hCount: x,
              vCount: y,
              itemBuilder: (context, index) {
                return SizedBox.fromSize(
                  size: childSize,
                  child: CLMediaView(
                    media: mediaList[index],
                    keepAspectRatio: keepAspectRatio,
                  ),
                );
              },
            )
        };
      },
    );
  }

  Widget itemBuilder(BuildContext context, int index) {
    return CLDecorateSquare(
      borderRadius: keepAspectRatio ? BorderRadius.circular(0) : null,
      child: CLMediaView(
        media: mediaList[index],
        keepAspectRatio: keepAspectRatio,
      ),
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
