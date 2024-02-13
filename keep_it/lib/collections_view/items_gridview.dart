import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CLMediaGridView extends ConsumerWidget {
  const CLMediaGridView({
    required this.items,
    required this.label,
    super.key,
    this.columns = 4,
    this.rows,
    this.additionalItems,
    this.physics,
  });
  final List<CLMedia> items;
  final String label;
  final int columns;
  final int? rows;
  final List<Widget>? additionalItems;
  static const crossAxisSpacing = 2.0;
  static const mainAxisSpacing = 2.0;
  final ScrollPhysics? physics;

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
      physics: physics,
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

        return GestureDetector(
          onTap: () => context.push('/item/${media.collectionId}/${media.id}'),
          child: ImageThumbnail(
            media: media,
            builder: (context, thumbnailFile) {
              return thumbnailFile.when(
                data: (file) => ImageView(
                  file: file,
                  overlayIcon: (media.type == CLMediaType.video)
                      ? Icons.play_arrow_sharp
                      : null,
                ),
                error: (_, __) => const BrokenImage(),
                loading: () => const Center(child: CircularProgressIndicator()),
              );
            },
          ),
        );
      },
      itemCount: limitCount + additionaItemsCount,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: columns,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
    );
  }
}
