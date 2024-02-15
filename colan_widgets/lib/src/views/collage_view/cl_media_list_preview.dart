import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../widgets/cl_decorate_square.dart';

// TODO(anandas): Try merging this to CLMediaCollage
class CLMediaListPreview extends ConsumerWidget {
  const CLMediaListPreview({
    required this.mediaList,
    required this.limit,
    super.key,
    this.whenNopreview,
  });

  final List<CLMedia> mediaList;
  final Widget? whenNopreview;

  final CLDimension limit;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mediaWithPreview = mediaList.where((e) {
      return File(e.path).existsSync();
    }).toList();
    if (mediaWithPreview.isEmpty) {
      return CLDecorateSquare(
        hasBorder: true,
        child: Center(
          child: whenNopreview,
        ),
      );
    }
    final CLDimension d;

    if (mediaWithPreview.length < limit.totalCount) {
      if (mediaWithPreview.length < limit.itemsInRow) {
        d = CLDimension(itemsInRow: mediaWithPreview.length, itemsInColumn: 1);
      } else {
        d = CLDimension(
          itemsInRow: limit.itemsInRow,
          itemsInColumn: (mediaWithPreview.length + limit.itemsInRow - 1) ~/
              limit.itemsInRow,
        );
      }
    } else {
      d = limit;
    }

    return CLDecorateSquare(
      child: CLMediaCollage.byMatrixSize(
        mediaWithPreview,
        hCount: d.itemsInRow,
        vCount: d.itemsInColumn,
        keepAspectRatio: true,
      ),
    );
  }
}
