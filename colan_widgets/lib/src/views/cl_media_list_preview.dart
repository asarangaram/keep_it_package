import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CLMediaListPreview extends ConsumerWidget {
  const CLMediaListPreview({
    required this.mediaList,
    required this.mediaCountInPreview,
    super.key,
    this.whenNopreview,
  });

  final List<CLMedia> mediaList;
  final Widget? whenNopreview;

  final CLDimension mediaCountInPreview;
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

    if (mediaWithPreview.length < mediaCountInPreview.totalCount) {
      if (mediaWithPreview.length < mediaCountInPreview.itemsInRow) {
        d = CLDimension(itemsInRow: mediaWithPreview.length, itemsInColumn: 1);
      } else {
        d = CLDimension(
          itemsInRow: mediaCountInPreview.itemsInRow,
          itemsInColumn:
              (mediaWithPreview.length + mediaCountInPreview.itemsInRow - 1) ~/
                  mediaCountInPreview.itemsInRow,
        );
      }
    } else {
      d = mediaCountInPreview;
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
