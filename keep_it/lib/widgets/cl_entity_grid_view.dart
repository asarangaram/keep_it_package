import 'package:colan_services/colan_services.dart';
import 'package:flutter/material.dart';

import 'package:store/store.dart';

class CLEntityGridView extends StatelessWidget {
  const CLEntityGridView({
    required this.identifier,
    required this.itemBuilder,
    required this.galleryMap,
    required this.columns,
    required this.labelBuilder,
    required this.bannersBuilder,
    super.key,
  });
  final String identifier;
  final List<GalleryGroupCLEntity<CLEntity>> galleryMap;
  final ItemBuilder itemBuilder;
  final int columns;

  final Widget? Function(
    BuildContext context,
    List<GalleryGroupCLEntity<CLEntity>> galleryMap,
    GalleryGroupCLEntity<CLEntity> gallery,
  ) labelBuilder;
  final List<Widget> Function(
    BuildContext,
    List<GalleryGroupCLEntity<CLEntity>>,
  ) bannersBuilder;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...bannersBuilder(context, galleryMap),
        Flexible(
          child: ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: galleryMap.length + 1,
            itemBuilder: (BuildContext context, int groupIndex) {
              if (groupIndex == galleryMap.length) {
                return SizedBox(
                  height: MediaQuery.of(context).viewPadding.bottom + 80,
                );
              }
              final gallery = galleryMap[groupIndex];
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
                header: labelBuilder(context, galleryMap, gallery),
              );
            },
          ),
        ),
      ],
    );
  }
}
