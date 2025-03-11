import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cl_entities.dart';
import '../models/gallery_group.dart';
import '../models/labeled_entity_groups.dart';
import '../models/tab_identifier.dart';
import '../providers/tap_state.dart';
import 'cl_grid.dart';

class CLEntityGalleryTab extends ConsumerStatefulWidget {
  const CLEntityGalleryTab({
    required this.tabIdentifier,
    required this.tab,
    required this.itemBuilder,
    required this.labelBuilder,
    required this.headerWidgetsBuilder,
    required this.footerWidgetsBuilder,
    required this.columns,
    super.key,
  });
  final TabIdentifier tabIdentifier;
  final LabelledEntityGroups tab;
  final int columns;
  final Widget Function(BuildContext context, CLEntity item) itemBuilder;

  final Widget? Function(
    BuildContext context,
    List<GalleryGroupCLEntity<CLEntity>> galleryMap,
    GalleryGroupCLEntity<CLEntity> gallery,
  ) labelBuilder;
  final List<Widget> Function(
    BuildContext,
    List<GalleryGroupCLEntity<CLEntity>>,
  ) headerWidgetsBuilder;
  final List<Widget> Function(
    BuildContext,
    List<GalleryGroupCLEntity<CLEntity>>,
  ) footerWidgetsBuilder;

  @override
  ConsumerState<CLEntityGalleryTab> createState() => CLEntityGalleryTabState();
}

class CLEntityGalleryTabState extends ConsumerState<CLEntityGalleryTab> {
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset:
          ref.read(tabScrollPositionProvider(widget.tabIdentifier)),
    );

    // Listen for scroll changes
    _scrollController.addListener(_listener);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_listener);
    _scrollController.dispose();
    super.dispose();
  }

  void _listener() {
    ref.read(tabScrollPositionProvider(widget.tabIdentifier).notifier).state =
        _scrollController.offset;
  }

  @override
  Widget build(BuildContext context) {
    final galleryGroups = widget.tab.galleryGroups;
    return Column(
      children: [
        ...widget.headerWidgetsBuilder(context, galleryGroups),
        Flexible(
          child: ListView.builder(
            controller: _scrollController,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: galleryGroups.length + 1,
            itemBuilder: (BuildContext context, int groupIndex) {
              if (groupIndex == galleryGroups.length) {
                return SizedBox(
                  height: MediaQuery.of(context).viewPadding.bottom + 80,
                );
              }
              final gallery = galleryGroups[groupIndex];
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
                header: widget.labelBuilder(context, galleryGroups, gallery),
              );
            },
          ),
        ),
        ...widget.footerWidgetsBuilder(context, galleryGroups),
      ],
    );
  }
}
