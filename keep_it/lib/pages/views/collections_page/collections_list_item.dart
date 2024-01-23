import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/pages/views/collections_page/collection_preview.dart';
import 'package:store/store.dart';

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
      height: previewSize.toDouble(),
      child: CLListTile(
        isSelected: isSelected ?? false,
        title: CLText.large(collection.label),
        subTitle: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Flexible(
              child: CLText.small(
                collection.description ?? '',
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
                loading: () => const CLIcon.small(Icons.timer),
              ),
            ),
          ],
        ),
        leading: SizedBox.square(
          dimension: previewSize.toDouble(),
          child: CollectionPreview(backgroundColor: backgroundColor),
        ),
        onTap: onTap,
      ),
    );
  }
}
