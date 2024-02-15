import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../basics/cl_matrix.dart';
import '../../extensions/ext_double.dart';
import '../../models/cl_dimension.dart';
import '../../models/cl_media.dart';
import '../../services/image_services/cl_media_preview.dart';
import '../../basics/cl_decorate_square.dart';

class CLMediaCollage extends StatelessWidget {
  const CLMediaCollage._({
    required this.mediaList,
    required this.canScroll,
    required this.keepAspectRatio,
    required this.maxPageDimension,
    this.hCount,
    this.vCount,
    this.childSize,
    super.key,
    this.whenNopreview,
  });
  factory CLMediaCollage.byMatrixSize(
    List<CLMedia> mediaList, {
    required int hCount,
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
    );
  }
  factory CLMediaCollage.byChildSize(
    List<CLMedia> mediaList, {
    required Size childSize,
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

  @override
  Widget build(BuildContext context) {
    final mediaWithPreview = mediaList.where((e) {
      return File(e.path).existsSync();
    }).toList();
    if (mediaWithPreview.isEmpty) {
      return itemBuilder(
        context,
        whenNopreview,
      );
    }
    return LayoutBuilder(
      builder: (context, constraints) {
        final int x;
        final int? y;
        final double aspectRatio;
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
          aspectRatio = 1.0;
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
          aspectRatio = childSize!.width / childSize!.height;
        }
        return switch (y) {
          null => Matrix2D.scrollable(
              itemCount: mediaWithPreview.length,
              hCount: x,
              itemBuilder: (context, index) {
                return itemBuilder(
                  context,
                  CLMediaPreview(
                    media: mediaWithPreview[index],
                    keepAspectRatio: keepAspectRatio,
                  ),
                );
              },
            ),
          _ => Matrix2D(
              itemCount: mediaWithPreview.length,
              hCount: x,
              vCount: y,
              itemBuilder: (context, index) {
                return itemBuilder(
                  context,
                  CLMediaPreview(
                    media: mediaWithPreview[index],
                    keepAspectRatio: keepAspectRatio,
                  ),
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

  Widget itemBuilder(BuildContext context, Widget? child) {
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
