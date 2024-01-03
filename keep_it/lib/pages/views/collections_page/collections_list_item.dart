import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:store/store.dart';

import 'collection_preview.dart';

class CollectionsListItem extends ConsumerWidget {
  const CollectionsListItem(
    this.collection, {
    super.key,
    this.isSelected,
    required this.random,
    this.onTap,
  });

  final bool? isSelected;
  final Collection collection;
  final Random random;
  final Function()? onTap;
  final double previewSize = 128; // TODO: should come from settings

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final clustersAsync = ref.watch(clustersProvider(collection.id));

    return SizedBox(
      height: previewSize,
      child: CLListTile(
        isSelected: isSelected ?? false,
        title: CLText.large(collection.label),
        subTitle: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: CLText.small(
                collection.description ?? "",
                textAlign: TextAlign.start,
              ),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: clustersAsync.when(
                  data: (clusters) {
                    return CLText.small(
                      clusters.entries.length.toString(),
                      textAlign: TextAlign.end,
                    );
                  },
                  error: (_, __) => const CLIcon.small(Icons.error),
                  loading: () => const CLIcon.small(Icons.timer)),
            )
          ],
        ),
        leading: SizedBox.square(
          dimension: previewSize,
          child: CollectionPreview(random: random),
        ),
        onTap: onTap,
      ),
    );
  }
}
