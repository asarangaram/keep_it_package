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
        final Widget? icon;
        if (clMediaList != null) {
          final mediaWithPreview = clMediaList
              .where((e) => File(e.previewFileName).existsSync())
              .toList()
              .firstNItems(4);

          if (mediaWithPreview.isEmpty) {
            icon = CLGridItemSquare(
              hasBorder: true,
              child: Center(
                child: CLText.veryLarge(tag.label.characters.first),
              ),
            );
          } else {
            final (hCount, vCount) = switch (mediaWithPreview.length) {
              1 => (1, 1),
              2 => (2, 1),
              _ => (2, 2)
            };
            icon = CLMediaGridViewFixed(
              mediaList: mediaWithPreview,
              hCount: hCount,
              vCount: vCount,
            );
          }
        } else {
          icon = CLGridItemSquare(
            hasBorder: true,
            child: Center(
              child: CLText.veryLarge(tag.label.characters.first),
            ),
          );
        }

        if (!isTile) {
          return icon;
        }
        return Row(
          children: [
            SizedBox.square(dimension: 128, child: icon),
            Flexible(
              child: SizedBox(
                height: 128,
                width: double.infinity,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CLText.large(tag.label),
                    CLText.small(
                      tag.description ?? '',
                      textAlign: TextAlign.start,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
