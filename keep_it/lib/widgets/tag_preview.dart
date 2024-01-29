import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import 'from_store/items_in_tag.dart';

class TagPreview extends ConsumerWidget {
  const TagPreview({
    required this.tag,
    super.key,
    this.isSelected,
  }) : isTile = false;
  const TagPreview.asTile({
    required this.tag,
    super.key,
    this.isSelected,
  }) : isTile = true;
  final Tag tag;
  final bool isTile;
  final bool? isSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return LoadItemsInTag(
      id: tag.id,
      limit: 4,
      buildOnData: (clMediaList) {
        Widget? icon;
        List<CLMedia>? mediaWithPreview;
        if (clMediaList != null) {
          mediaWithPreview = clMediaList
              .where((e) => File(e.previewFileName).existsSync())
              .toList()
              .firstNItems(4);
        }

        if (mediaWithPreview?.isNotEmpty ?? false) {
          final (hCount, vCount) = switch (mediaWithPreview!.length) {
            1 => (1, 1),
            2 => (2, 1),
            _ => (2, 2)
          };

          icon = icon = CLDecorateSquare(
            child: CLMediaGridView.byMatrixSize(
              mediaWithPreview,
              hCount: hCount,
              vCount: vCount,
              keepAspectRatio: false,
            ),
          );
        }
        if (!isTile) {
          return icon ??
              CLDecorateSquare(
                hasBorder: true,
                child: Center(
                  child: CLText.veryLarge(tag.label.characters.first),
                ),
              );
        }
        return SizedBox(
          height: icon != null ? 128 : null,
          child: ListTile(
            title: CLText.large(
              tag.label,
              textAlign: TextAlign.start,
            ),
            subtitle: CLText.small(
              tag.description ?? '',
              textAlign: TextAlign.start,
            ),
          ),
        );
      },
    );
  }
}
