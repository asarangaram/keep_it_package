import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CLMediaGrid extends ConsumerWidget {
  const CLMediaGrid({
    required this.mediaList,
    required this.onTapMedia,
    required this.itemBuilder,
    this.additionalItems,
    this.columns = 4,
    this.rows,
    this.physics = const NeverScrollableScrollPhysics(),
    this.header,
    this.footer,
    this.crossAxisSpacing = 2.0,
    this.mainAxisSpacing = 2.0,
    super.key,
  });
  final List<CLMedia> mediaList;
  final List<Widget>? additionalItems;
  final int columns;
  final int? rows;
  final ScrollPhysics? physics;
  final Widget? header;
  final Widget? footer;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final void Function(CLMedia media)? onTapMedia;
  final Widget Function(BuildContext context, CLMedia media) itemBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int limitCount;
    final additionaItemsCount = additionalItems?.length ?? 0;
    final totalItems = mediaList.length + additionaItemsCount;
    if (rows == null) {
      limitCount = mediaList.length;
    } else {
      limitCount = min(totalItems, rows! * columns) - additionaItemsCount;
    }
    if (mediaList.isEmpty) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null) header!,
        GridView.builder(
          padding: const EdgeInsets.only(top: 2),
          shrinkWrap: true,
          physics: physics,
          itemBuilder: (context, index) {
            if (index >= limitCount) {
              if (index - limitCount < additionalItems!.length) {
                return additionalItems![index - limitCount];
              }
              /* return  */
            }
            if (index >= mediaList.length) {
              return Container();
            }
            final media = mediaList[index];

            return GestureDetector(
              onTap: onTapMedia == null
                  ? null
                  : () {
                      onTapMedia?.call(media);
                    },
              child: itemBuilder(context, media),
            );
          },
          itemCount: limitCount + additionaItemsCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
          ),
        ),
        if (footer != null) footer!,
      ],
    );
  }
}
