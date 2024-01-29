import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

class CollectionBasePreview extends ConsumerWidget {
  const CollectionBasePreview({
    required this.item,
    required this.mediaList,
    required this.mediaCountInPreview,
    super.key,
    this.keepAspectRatio = false,
  });
  final CollectionBase item;
  final List<CLMedia>? mediaList;
  final bool keepAspectRatio;

  final CLDimension mediaCountInPreview;
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<CLMedia>? mediaWithPreview;
    if (mediaList?.isNotEmpty ?? false) {
      mediaWithPreview = mediaList!
          .where((e) => File(e.previewFileName).existsSync())
          .toList()
          .firstNItems(mediaCountInPreview.totalCount);
    }
    if (mediaWithPreview?.isEmpty ?? true) {
      return CLDecorateSquare(
        hasBorder: true,
        child: Center(
          child: CLText.veryLarge(item.label.characters.first),
        ),
      );
    }
    final CLDimension d;

    if (mediaWithPreview!.length < mediaCountInPreview.totalCount) {
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
      hasBorder: keepAspectRatio,
      child: CLMediaGridView.byMatrixSize(
        mediaWithPreview,
        hCount: d.itemsInRow,
        vCount: d.itemsInColumn,
        keepAspectRatio: keepAspectRatio,
      ),
    );
  }
}
