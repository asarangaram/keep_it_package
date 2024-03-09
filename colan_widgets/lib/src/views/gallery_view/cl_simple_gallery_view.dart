import 'package:flutter/material.dart';

import '../../basics/cl_button.dart';
import '../../basics/cl_text.dart';
import '../appearance/keep_it_main_view.dart';

import 'widgets/cl_grid.dart';

@immutable
class GalleryGroup<T> {
  const GalleryGroup(this.items, {this.label});
  final String? label;
  final List<T> items;
}

class CLSimpleGalleryView<T> extends StatelessWidget {
  const CLSimpleGalleryView({
    required this.galleryMap,
    required this.title,
    required this.emptyState,
    required this.tagPrefix,
    required this.itemBuilder,
    required this.columns,
    this.onPickFiles,
    super.key,
    this.onPop,
    this.onRefresh,
  });

  final String title;
  final List<GalleryGroup<T>> galleryMap;
  final int columns;

  final Widget emptyState;
  final String tagPrefix;
  final void Function()? onPickFiles;
  final void Function()? onPop;
  final Future<void> Function()? onRefresh;

  final Widget Function(
    BuildContext context,
    T item, {
    required GlobalKey<State<StatefulWidget>> quickMenuScopeKey,
  }) itemBuilder;

  @override
  Widget build(BuildContext context) {
    return KeepItMainView(
      title: title,
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
          child: galleryMap.isEmpty
              ? emptyState
              : CLSimpleGalleryView0(
                  galleryMap: galleryMap,
                  itemBuilder: (context, item) {
                    return itemBuilder(
                      context,
                      item,
                      quickMenuScopeKey: quickMenuScopeKey,
                    );
                  },
                  columns: columns,
                ),
        );
      },
    );
  }
}

class CLSimpleGalleryView0<T> extends StatefulWidget {
  const CLSimpleGalleryView0({
    required this.galleryMap,
    required this.itemBuilder,
    required this.columns,
    super.key,
  });

  final List<GalleryGroup<T>> galleryMap;
  final int columns;

  final Widget Function(BuildContext context, T item) itemBuilder;

  @override
  State<CLSimpleGalleryView0<T>> createState() =>
      _CLSimpleGalleryView0State<T>();
}

class _CLSimpleGalleryView0State<T> extends State<CLSimpleGalleryView0<T>> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: widget.galleryMap.length,
          itemBuilder: (BuildContext context, int index) {
            return CLGrid(
              mediaList: widget.galleryMap[index].items,
              columns: widget.columns,
              itemBuilder: (context, item) {
                return Stack(
                  children: [
                    widget.itemBuilder(context, item),
                  ],
                );
              },
              header: widget.galleryMap[index].label == null
                  ? null
                  : Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: CLText.large(
                        widget.galleryMap[index].label!,
                        textAlign: TextAlign.start,
                      ),
                    ),
            );
          },
        ),
      ],
    );
  }
}
