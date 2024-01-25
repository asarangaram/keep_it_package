import 'dart:io';
import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

import 'from_store/items_in_tag.dart';
import 'media_preview.dart';

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
            final (c, r) = switch (mediaWithPreview.length) {
              1 => (1, 1),
              2 => (2, 1),
              _ => (2, 2)
            };
            icon = CLGridItemSquare(
              child: Matrix2DFixed(
                itemBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: const EdgeInsets.all(1),
                    child: MediaItemPreview(mediaItem: mediaWithPreview[index]),
                  );
                },
                hCount: c,
                vCount: r,
                itemCount: min(r * c, mediaWithPreview.length),
              ),
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

class CLGridItemSquare extends StatelessWidget {
  const CLGridItemSquare({
    super.key,
    this.child,
    this.hasBorder = false,
  });

  final Widget? child;
  final bool hasBorder;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: SizedBox.square(
        dimension: 128,
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: hasBorder ? Border.all() : null,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
