import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'from_store/collection_count.dart';
import 'tag_preview.dart';

class TagsListItem extends ConsumerWidget {
  const TagsListItem(
    this.tag, {
    required this.backgroundColor,
    super.key,
    this.isSelected,
    this.onTap,
    this.previewSize = 128,
  });

  final bool? isSelected;
  final Tag tag;

  final void Function()? onTap;
  final Color backgroundColor;
  final int previewSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SizedBox(
      height: previewSize.toDouble() + 60,
      child: CLListTile(
        isSelected: isSelected ?? false,
        title: CLText.large(tag.label),
        subTitle: SizedBox(
          height: previewSize.toDouble(),
          width: double.infinity,
          child: Stack(
            children: [
              CLText.small(
                tag.description ?? '',
                textAlign: TextAlign.start,
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: CollectionCount(
                  tagId: tag.id,
                  buildOnData: (count) => CLText.small(
                    count.toString(),
                    textAlign: TextAlign.end,
                  ),
                ),
              ),
            ],
          ),
        ),
        leading: SizedBox.square(
          dimension: previewSize.toDouble(),
          child: CLGridItemSquare(backgroundColor: backgroundColor),
        ),
        onTap: onTap,
      ),
    );
  }
}
