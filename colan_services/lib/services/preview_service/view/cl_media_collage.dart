import 'dart:io';
import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

class CLMediaCollage extends StatelessWidget {
  const CLMediaCollage._({
    required this.mediaList,
    required this.canScroll,
    required this.keepAspectRatio,
    required this.maxPageDimension,
    required this.itemBuilder,
    this.hCount,
    this.vCount,
    this.childSize,
    super.key,
    this.whenNopreview,
  });
  factory CLMediaCollage.byMatrixSize(
    List<CLMedia> mediaList, {
    required int hCount,
    required Widget Function(BuildContext context, int index) itemBuilder,
    int? vCount,
    Key? key,
    bool? keepAspectRatio,
    CLDimension? maxPageDimension,
    Widget? whenNopreview,
  }) {
    return CLMediaCollage._(
      mediaList: mediaList,
      key: key,
      hCount: hCount,
      vCount: vCount,
      keepAspectRatio: keepAspectRatio ?? false,
      canScroll: vCount == null,
      maxPageDimension: maxPageDimension ??
          const CLDimension(itemsInRow: 6, itemsInColumn: 6),
      whenNopreview: whenNopreview,
      itemBuilder: itemBuilder,
    );
  }
  factory CLMediaCollage.byChildSize(
    List<CLMedia> mediaList, {
    required Size childSize,
    required Widget Function(BuildContext context, int index) itemBuilder,
    Key? key,
    bool? keepAspectRatio,
    bool canScroll = false,
    CLDimension? maxPageDimension,
    Widget? whenNopreview,
  }) {
    return CLMediaCollage._(
      mediaList: mediaList,
      childSize: childSize,
      key: key,
      keepAspectRatio: keepAspectRatio ?? false,
      canScroll: canScroll,
      maxPageDimension: maxPageDimension ??
          const CLDimension(itemsInRow: 6, itemsInColumn: 6),
      whenNopreview: whenNopreview,
      itemBuilder: itemBuilder,
    );
  }

  final List<CLMedia> mediaList;
  final int? hCount;
  final int? vCount;
  final bool keepAspectRatio;
  final Size? childSize;
  final bool canScroll;
  final CLDimension maxPageDimension;
  final Widget? whenNopreview;
  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final mediaWithPreview = mediaList.where((e) {
      return File(TheStore.of(context).getMediaPath(e)).existsSync();
    }).toList();
    if (mediaWithPreview.isEmpty) {
      return onBuildItem(
        context,
        whenNopreview,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final int x;
        final int? y;

        if (childSize == null) {
          if (vCount != null) {
            final totalCount = hCount! * vCount!;
            if (mediaWithPreview.length < totalCount) {
              if (mediaWithPreview.length < hCount!) {
                x = mediaWithPreview.length;
                y = 1;
              } else {
                x = hCount!;
                y = (mediaWithPreview.length + hCount! - 1) ~/ hCount!;
              }
            } else {
              x = hCount!;
              y = vCount;
            }
          } else {
            x = hCount!;
            y = vCount;
          }
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
          null => Matrix2D.scrollable(
              itemCount: mediaWithPreview.length,
              hCount: x,
              itemBuilder: (context, index) {
                return onBuildItem(
                  context,
                  itemBuilder(context, index),
                );
              },
            ),
          _ => Matrix2D(
              itemCount: mediaWithPreview.length,
              hCount: x,
              vCount: y,
              itemBuilder: (context, index) {
                return onBuildItem(
                  context,
                  itemBuilder(context, index),
                );
              },
            )
        };
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

  Widget onBuildItem(BuildContext context, Widget? child) {
    if (childSize != null) {
      return SizedBox.fromSize(
        size: childSize,
        child: Center(child: child),
      );
    }
    return CLAspectRationDecorated(
      padding: const EdgeInsets.all(1),
      child: child,
    );
  }
}
