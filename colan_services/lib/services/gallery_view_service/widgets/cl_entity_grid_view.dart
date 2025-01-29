import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:store/store.dart' show CLEntity, GalleryGroupCLEntity;

import 'core/cl_grid.dart';

class CLEntityGridView extends ConsumerStatefulWidget {
  const CLEntityGridView({
    required this.itemBuilder,
    required this.galleryMap,
    required this.columns,
    required this.labelBuilder,
    required this.bannersBuilder,
    super.key,
  });

  final List<GalleryGroupCLEntity<CLEntity>> galleryMap;
  final Widget Function(BuildContext context, CLEntity item) itemBuilder;
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
  ConsumerState<CLEntityGridView> createState() => _CLEntityGridViewState();
}

class _CLEntityGridViewState extends ConsumerState<CLEntityGridView> {
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController =
        ScrollController(initialScrollOffset: ref.read(scrollPositionProvider));

    // Listen for scroll changes
    _scrollController.addListener(() {
      ref.read(scrollPositionProvider.notifier).state =
          _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ...widget.bannersBuilder(context, widget.galleryMap),
        Flexible(
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: widget.galleryMap.length + 1,
            itemBuilder: (BuildContext context, int groupIndex) {
              if (groupIndex == widget.galleryMap.length) {
                return SizedBox(
                  height: MediaQuery.of(context).viewPadding.bottom + 80,
                );
              }
              final gallery = widget.galleryMap[groupIndex];
              return CLGrid<CLEntity>(
                itemCount: gallery.items.length,
                columns: widget.columns,
                itemBuilder: (context, itemIndex) {
                  final itemWidget = widget.itemBuilder(
                    context,
                    gallery.items[itemIndex],
                  );

                  return itemWidget;
                },
                header:
                    widget.labelBuilder(context, widget.galleryMap, gallery),
              );
            },
          ),
        ),
      ],
    );
  }
}

final scrollPositionProvider = StateProvider<double>((ref) {
  return 0;
});
