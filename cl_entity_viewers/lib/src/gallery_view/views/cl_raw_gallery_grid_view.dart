import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/viewer_entity_mixin.dart';

import '../providers/grouped_media_provider.dart';
import '../models/tab_identifier.dart';

import '../providers/scroll_position.dart';
import 'cl_grid.dart';

class CLRawGalleryGridView extends ConsumerStatefulWidget {
  const CLRawGalleryGridView(
      {required this.viewIdentifier,
      required this.incoming,
      required this.itemBuilder,
      required this.labelBuilder,
      required this.bannersBuilder,
      required this.columns,
      required this.whenEmpty,
      super.key,
      this.draggableMenuBuilder});
  final ViewIdentifier viewIdentifier;
  final List<ViewerEntityMixin> incoming;
  final int columns;
  final Widget Function(BuildContext context, ViewerEntityMixin item,
      List<ViewerEntityMixin> entities) itemBuilder;

  final Widget? Function(
    BuildContext context,
    List<ViewerEntityGroup<ViewerEntityMixin>> galleryMap,
    ViewerEntityGroup<ViewerEntityMixin> gallery,
  ) labelBuilder;
  final List<Widget> Function(
    BuildContext,
    List<ViewerEntityGroup<ViewerEntityMixin>>,
  ) bannersBuilder;
  final Widget whenEmpty;

  final Widget Function(
    BuildContext context, {
    required GlobalKey<State<StatefulWidget>> parentKey,
  })? draggableMenuBuilder;

  @override
  ConsumerState<CLRawGalleryGridView> createState() =>
      CLRawGalleryGridViewState();
}

class CLRawGalleryGridViewState extends ConsumerState<CLRawGalleryGridView> {
  final GlobalKey parentKey = GlobalKey();
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController(
      initialScrollOffset:
          ref.read(tabScrollPositionProvider(widget.viewIdentifier)),
    );

    // Listen for scroll changes
    _scrollController.addListener(() {
      ref
          .read(tabScrollPositionProvider(widget.viewIdentifier).notifier)
          .state = _scrollController.offset;
    });
  }

  @override
  Widget build(BuildContext context) {
    final galleryGroups = ref.watch(
      groupedMediaProvider(
        MapEntry(
          widget.viewIdentifier,
          widget.incoming,
        ),
      ),
    );
    final child = Column(
      children: [
        ...widget.bannersBuilder(context, galleryGroups),
        if (galleryGroups.isEmpty)
          Flexible(child: widget.whenEmpty)
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
                        context, gallery.items[itemIndex], widget.incoming);

                    return itemWidget;
                  },
                  header: widget.labelBuilder(context, galleryGroups, gallery),
                );
              },
            ),
          ),
      ],
    );
    if (widget.draggableMenuBuilder == null) return child;
    return Stack(
      key: parentKey,
      children: [
        child,
        if (widget.draggableMenuBuilder != null)
          widget.draggableMenuBuilder!(context, parentKey: parentKey),
      ],
    );
  }
}
