import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart';

class CLEntityGridView extends ConsumerWidget {
  const CLEntityGridView({
    required this.identifier,
    required this.itemBuilder,
    required this.galleryMap,
    required this.columns,
    required this.banners,
    required this.labelBuilder,
    super.key,
  });
  final String identifier;
  final List<GalleryGroupCLEntity<CLEntity>> galleryMap;
  final ItemBuilder itemBuilder;
  final int columns;
  final List<Widget> banners;
  final Widget? Function(
    BuildContext context,
    GalleryGroupCLEntity<CLEntity> gallery,
  ) labelBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: galleryMap.length + banners.length + 1,
      itemBuilder: (BuildContext context, int groupIndex) {
        if (groupIndex < banners.length) {
          return banners[groupIndex];
        }
        if (groupIndex == galleryMap.length + banners.length) {
          return SizedBox(
            height: MediaQuery.of(context).viewPadding.bottom + 80,
          );
        }
        final gallery = galleryMap[groupIndex - banners.length];
        return CLGrid<CLEntity>(
          itemCount: gallery.items.length,
          columns: columns,
          itemBuilder: (context, itemIndex) {
            final itemWidget = itemBuilder(
              context,
              gallery.items[itemIndex],
            );

            return itemWidget;
          },
          header: labelBuilder(context, gallery),
        );
      },
    );
  }
}
