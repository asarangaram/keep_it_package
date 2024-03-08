import 'package:flutter/material.dart';

import '../../basics/cl_button.dart';
import '../../basics/cl_text.dart';
import '../appearance/keep_it_main_view.dart';

import 'widgets/cl_grid.dart';

@immutable
class GalleryGroup {
  const GalleryGroup(this.items, {this.label});
  final String? label;
  final List<Object> items;
}

class CLSimpleGalleryView extends StatelessWidget {
  const CLSimpleGalleryView({
    required this.galleryMap,
    required this.label,
    required this.emptyState,
    required this.tagPrefix,
    required this.itemBuilder,
    required this.columns,
    this.onPickFiles,
    super.key,
    this.onPop,
    this.onRefresh,
  });

  final String label;
  final List<GalleryGroup> galleryMap;
  final int columns;

  final Widget emptyState;
  final String tagPrefix;
  final void Function()? onPickFiles;
  final void Function()? onPop;
  final Future<void> Function()? onRefresh;

  final Widget Function(
    BuildContext context,
    Object item, {
    required GlobalKey<State<StatefulWidget>> quickMenuScopeKey,
  }) itemBuilder;

  @override
  Widget build(BuildContext context) {
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
          child: galleryMap.isEmpty
              ? emptyState
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: galleryMap.length,
                  itemBuilder: (BuildContext context, int index) {
                    return CLGrid(
                      mediaList: galleryMap[index].items,
                      columns: columns,
                      itemBuilder: (context, item) {
                        return itemBuilder(
                          context,
                          item,
                          quickMenuScopeKey: quickMenuScopeKey,
                        );
                      },
                      header: galleryMap[index].label == null
                          ? null
                          : Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: CLText.large(
                                galleryMap[index].label!,
                                textAlign: TextAlign.start,
                              ),
                            ),
                    );
                  },
                ),
        );
      },
    );
  }
}
