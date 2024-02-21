import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../basics/cl_button.dart';
import '../../basics/cl_text.dart';
import '../../models/cl_media.dart';
import '../appearance/keep_it_main_view.dart';
import '../huge_list_view/events.dart';
import '../huge_list_view/huge_list.dart';

import 'widgets/cl_media_grid_lazy.dart';

@immutable
class GalleryGroup {
  const GalleryGroup(this.items, {required this.label});
  final String label;
  final List<Object> items;
}

class CLGalleryView extends ConsumerStatefulWidget {
  const CLGalleryView({
    required this.galleryMap,
    required this.label,
    required this.emptyState,
    required this.tagPrefix,
    required this.onPickFiles,
    required this.itemBuilder,
    super.key,
    this.header,
    this.footer,
    this.onPop,
  });
  final String label;
  final List<GalleryGroup> galleryMap;

  final Widget? header;
  final Widget? footer;
  final Widget emptyState;
  final String tagPrefix;
  final void Function() onPickFiles;
  final void Function()? onPop;

  final Widget Function(BuildContext context, Object item) itemBuilder;

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => GalleryState();
}

class GalleryState extends ConsumerState<CLGalleryView> {
  // ignore: unused_field
  late ItemScrollController _itemScroller;
  @override
  void initState() {
    _itemScroller = ItemScrollController();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final itemsMap = widget.galleryMap;

    return KeepItMainView(
      title: widget.label,
      onPop: widget.onPop,
      actionsBuilder: [
        (context, quickMenuScopeKey) => CLButtonIcon.standard(
              Icons.add,
              onTap: widget.onPickFiles,
            ),
      ],
      pageBuilder: (context, quickMenuScopeKey) {
        return HugeListView<List<dynamic>>(
          startIndex: 0,
          totalCount: itemsMap.length,
          labelTextBuilder: (index) => itemsMap[index].label,
          emptyResultBuilder: (_) {
            final children = <Widget>[];
            if (widget.header != null) {
              children.add(widget.header!);
            }
            children.add(
              Expanded(
                child: widget.emptyState,
              ),
            );
            if (widget.footer != null) {
              children.add(widget.footer!);
            }
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: children,
            );
          },
          itemBuilder: (BuildContext context, int index) {
            final w = Padding(
              padding: const EdgeInsets.all(8),
              child: CLMediaGridLazy(
                mediaList: itemsMap[index].items,
                itemBuilder: widget.itemBuilder,
                index: index,
                currentIndexStream: Bus.instance
                    .on<GalleryIndexUpdatedEvent>()
                    .where((event) => event.tag == widget.tagPrefix)
                    .map((event) => event.index),
                header: Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: CLText.large(
                    itemsMap[index].label,
                    textAlign: TextAlign.start,
                  ),
                ),
              ),
            );
            if (index == 0 && widget.header != null) {
              return Column(
                children: [if (widget.header != null) widget.header!, w],
              );
            }
            if (index == (itemsMap.length - 1) && widget.footer != null) {
              return Column(
                children: [w, if (widget.footer != null) widget.footer!],
              );
            }
            return w;
          },
          firstShown: (int firstIndex) {
            Bus.instance
                .fire(GalleryIndexUpdatedEvent(widget.tagPrefix, firstIndex));
          },
        );
      },
    );
  }
}
