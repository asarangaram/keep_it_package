import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/labeled_entity_groups.dart';
import '../../models/tab_identifier.dart';
import '../../models/viewer_entity_mixin.dart';
import '../providers/tap_state.dart';
import 'cl_grid.dart';

class CLEntityGalleryTab extends ConsumerStatefulWidget {
  const CLEntityGalleryTab({
    required this.tabIdentifier,
    required this.tab,
    required this.itemBuilder,
    required this.labelBuilder,
    required this.bannersBuilder,
    required this.columns,
    super.key,
  });
  final TabIdentifier tabIdentifier;
  final ViewerEntityGroups tab;
  final int columns;
  final Widget Function(BuildContext context, ViewerEntityMixin item)
      itemBuilder;

  final Widget? Function(
    BuildContext context,
    List<ViewerEntityGroup<ViewerEntityMixin>> galleryMap,
    ViewerEntityGroup<ViewerEntityMixin> gallery,
  ) labelBuilder;
  final List<Widget> Function(
    BuildContext,
    List<ViewerEntityGroup<ViewerEntityMixin>>,
  ) bannersBuilder;

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
    _scrollController.addListener(() {
      ref.read(tabScrollPositionProvider(widget.tabIdentifier).notifier).state =
          _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final galleryGroups = widget.tab.galleryGroups;
    return Column(
      children: [
        ...widget.bannersBuilder(context, galleryGroups),
        if (galleryGroups.isEmpty)
          throw Exception("WhenEmpty should come here")
        //const Flexible(child: throw Exce)
        else
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
                return CLGrid<ViewerEntityMixin>(
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
      ],
    );
  }
}
