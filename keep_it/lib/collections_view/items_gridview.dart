import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CLMediaGridView extends ConsumerWidget {
  const CLMediaGridView({
    required this.items,
    required this.label,
    super.key,
    this.columns = 4,
    this.rows,
    this.additionalItems,
  });
  final List<CLMedia> items;
  final String label;
  final int columns;
  final int? rows;
  final List<Widget>? additionalItems;
  static const crossAxisSpacing = 2.0;
  static const mainAxisSpacing = 2.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final int limitCount;
    final additionaItemsCount = additionalItems?.length ?? 0;
    final totalItems = items.length + additionaItemsCount;
    if (rows == null) {
      limitCount = items.length;
    } else {
      limitCount = min(totalItems, rows! * columns) - additionaItemsCount;
    }

    return GridView.builder(
      padding: const EdgeInsets.only(top: 2),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        if (index >= limitCount) {
          if (index - limitCount < additionalItems!.length) {
            return additionalItems![index - limitCount];
          } 
          /* return  */
        }
        if (index >= items.length) {
          return Container();
        }
        final media = items[index];
        return CLMediaPreview(
          media: media,
          keepAspectRatio: false,
        );
      },
      itemCount: limitCount + additionaItemsCount,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
    );
  }
}
