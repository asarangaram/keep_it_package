import 'package:colan_widgets/src/views/huge_list_view/huge_list_basic.dart';
import 'package:flutter/material.dart';

import '../../basics/cl_button.dart';
import '../../basics/cl_text.dart';
import '../appearance/keep_it_main_view.dart';
import '../huge_list_view/events.dart';

import 'cl_gallery_view.dart';
import 'widgets/cl_grid_lazy.dart';

class CLGalleryViewBasic extends StatelessWidget {
  const CLGalleryViewBasic({
    required this.galleryMap,
    required this.label,
    required this.emptyState,
    required this.tagPrefix,
    required this.itemBuilder,
    required this.labelTextBuilder,
    required this.columns,
    this.onPickFiles,
    super.key,
    this.header,
    this.footer,
    this.onPop,
    this.onRefresh,
    this.isScrollablePositionedList = true,
  });

  final String label;
  final List<GalleryGroup> galleryMap;
  final int columns;
  final Widget? header;
  final Widget? footer;
  final Widget emptyState;
  final String tagPrefix;
  final void Function()? onPickFiles;
  final void Function()? onPop;
  final Future<void> Function()? onRefresh;
  final bool isScrollablePositionedList;

  final Widget Function(
    BuildContext context,
    Object item, {
    required GlobalKey<State<StatefulWidget>> quickMenuScopeKey,
  }) itemBuilder;
  final String Function(int) labelTextBuilder;

  @override
  Widget build(BuildContext context) {
    final itemsMap = galleryMap;

    return KeepItMainView(
      title: label,
      onPop: onPop,
      actionsBuilder: [
        if (onPickFiles != null)
          (context, quickMenuScopeKey) => CLButtonIcon.standard(
                Icons.add,
                onTap: onPickFiles,
              ),
      ],
      pageBuilder: (context, quickMenuScopeKey) {
        return RefreshIndicator(
          onRefresh: onRefresh ?? () async {},
          key: ValueKey('$tagPrefix Refresh'),
          child: HugeListViewBasic<List<dynamic>>(
            totalCount: itemsMap.length,
            emptyResultBuilder: (_) {
              final children = <Widget>[];
              if (header != null) {
                children.add(header!);
              }
              children.add(
                Expanded(
                  child: emptyState,
                ),
              );
              if (footer != null) {
                children.add(footer!);
              }
              return Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: children,
              );
            },
            itemBuilder: (BuildContext context, int index) {
              final w = CLGridLazy(
                mediaList: itemsMap[index].items,
                columns: columns,
                itemBuilder: (context, item) {
                  return itemBuilder(
                    context,
                    item,
                    quickMenuScopeKey: quickMenuScopeKey,
                  );
                },
                index: index,
                currentIndexStream: Bus.instance
                    .on<GalleryIndexUpdatedEvent>()
                    .where((event) => event.tag == tagPrefix)
                    .map((event) => event.index),
                header: itemsMap[index].label == null
                    ? null
                    : Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: CLText.large(
                          itemsMap[index].label!,
                          textAlign: TextAlign.start,
                        ),
                      ),
              );
              if (index == 0 && header != null) {
                return Column(
                  children: [if (header != null) header!, w],
                );
              }
              if (index == (itemsMap.length - 1) && footer != null) {
                return Column(
                  children: [w, if (footer != null) footer!],
                );
              }
              return w;
            },
            tagPrefix: tagPrefix,
          ),
        );
      },
    );
  }
}
