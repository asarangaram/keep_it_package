import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'collection_preview.dart';

class CollectionsListItem extends ConsumerWidget {
  const CollectionsListItem(
    this.collection, {
    required this.backgroundColor,
    super.key,
    this.isSelected,
    this.onTap,
    this.previewSize = 128,
  });

  final bool? isSelected;
  final Collection collection;

  final void Function()? onTap;
  final Color backgroundColor;
  final int previewSize;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clustersAsync = ref.watch(clustersProvider(collection.id));

    return SizedBox(
      height: previewSize.toDouble() + 60,
      child: CLListTile(
        isSelected: isSelected ?? false,
        title: CLText.large(collection.label),
        subTitle: SizedBox(
          height: previewSize.toDouble(),
          width: double.infinity,
          child: Stack(
            children: [
              CLText.small(
                collection.description ?? '',
                textAlign: TextAlign.start,
              ),
              Positioned(
                right: 8,
                bottom: 8,
                child: clustersAsync.when(
                  data: (clusters) {
                    return CLText.small(
                      clusters.entries.length.toString(),
                      textAlign: TextAlign.end,
                    );
                  },
                  error: (_, __) => const CLIcon.small(Icons.error),
                  loading: () => const CLIcon.small(Icons.timer),
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
