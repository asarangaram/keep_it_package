import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../basics/cl_button.dart';
import '../../basics/cl_refresh_indicator.dart';
import '../../basics/cl_text.dart';
import '../../extensions/ext_cl_menu_item.dart';
import '../../models/cl_menu_item.dart';
import '../appearance/keep_it_main_view.dart';
import '../draggable/draggable_menu.dart';
import '../draggable/menu.dart';
import '../draggable/menu_control.dart';
import 'model/gallery_group.dart';
import 'selection/selectable_item.dart';
import 'selection/selectable_label.dart';
import 'selection/selection_count.dart';
import 'widgets/cl_grid.dart';

typedef QuickMenuScopeKey = GlobalKey<State<StatefulWidget>>;
typedef ItemBuilder<T> = Widget Function(
  BuildContext context,
  T item, {
  required QuickMenuScopeKey quickMenuScopeKey,
});

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
    this.onRefresh,
    this.selectionActions,
  });

  final String title;
  final List<GalleryGroup<T>> galleryMap;
  final int columns;

  final Widget emptyState;
  final String tagPrefix;
  final void Function()? onPickFiles;

  final Future<void> Function()? onRefresh;
  final List<CLMenuItem> Function(BuildContext context, List<T> selectedItems)?
      selectionActions;
  final ItemBuilder<T> itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (galleryMap.isEmpty) {
      return KeepItMainView(
        key: ValueKey('KeepItMainView $tagPrefix'),
        title: title,
        actionsBuilder: [
          if (onPickFiles != null)
            (context, quickMenuScopeKey) => CLButtonIcon.standard(
                  Icons.add,
                  onTap: onPickFiles,
                ),
        ],
        pageBuilder: (context, quickMenuScopeKey) => emptyState,
      );
    } else {
      return ProviderScope(
        overrides: [
          menuControlNotifierProvider
              .overrideWith((ref) => MenuControlNotifier()),
        ],
        child: CLSimpleGalleryView0(
          title: title,
          onPickFiles: onPickFiles,
          galleryMap: galleryMap,
          itemBuilder: itemBuilder,
          columns: columns,
          tagPrefix: tagPrefix,
          onRefresh: onRefresh,
          selectionActions: selectionActions,
        ),
      );
    }
  }
}

class CLSimpleGalleryView0<T> extends StatefulWidget {
  const CLSimpleGalleryView0({
    required this.galleryMap,
    required this.title,
    required this.tagPrefix,
    required this.itemBuilder,
    required this.columns,
    required this.onPickFiles,
    required this.onRefresh,
    required this.selectionActions,
    super.key,
  });

  final String title;
  final List<GalleryGroup<T>> galleryMap;
  final int columns;

  final String tagPrefix;
  final void Function()? onPickFiles;

  final Future<void> Function()? onRefresh;

  final ItemBuilder<T> itemBuilder;
  final List<CLMenuItem> Function(BuildContext context, List<T> selectedItems)?
      selectionActions;

  @override
  State<CLSimpleGalleryView0<T>> createState() =>
      _CLSimpleGalleryView0State<T>();
}

class _CLSimpleGalleryView0State<T> extends State<CLSimpleGalleryView0<T>> {
  late List<GalleryGroupMutable<bool>> selectionMap;
  final GlobalKey parentKey = GlobalKey();
  bool isSelectionMode = false;
  @override
  void initState() {
    selectionMap = createBooleanList(widget.galleryMap);
    super.initState();
  }

  List<GalleryGroupMutable<bool>> createBooleanList(
    List<GalleryGroup<T>> originalList,
  ) {
    return originalList.map((galleryGroup) {
      // Map the items list to a list of booleans (initialized to false)
      final booleanItems = galleryGroup.items.map((item) => false).toList();
      return GalleryGroupMutable<bool>(booleanItems, label: galleryGroup.label);
    }).toList();
  }

  void toggleSelection(int groupIndex, int itemIndex) {
    selectionMap[groupIndex].items[itemIndex] =
        !selectionMap[groupIndex].items[itemIndex];
  }

  void selectGroup(int groupIndex, {required bool select}) {
    final group = selectionMap[groupIndex];

    for (var i = 0; i < group.items.length; i++) {
      group.items[i] = select;
    }
  }

  void selectAll({required bool select}) {
    for (var g = 0; g < selectionMap.length; g++) {
      final group = selectionMap[g];

      for (var i = 0; i < group.items.length; i++) {
        group.items[i] = select;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasSelection = widget.selectionActions != null &&
        isSelectionMode &&
        selectionMap.trueCount > 0;
    return KeepItMainView(
      title: widget.title,
      actionsBuilder: [
        if (widget.selectionActions != null)
          (context, quickMenuScopeKey) => CLButtonText.small(
                isSelectionMode ? 'Done' : 'Select',
                onTap: () {
                  setState(() {
                    isSelectionMode = !isSelectionMode;
                  });
                },
              ),
        if (!isSelectionMode && widget.onPickFiles != null)
          (context, quickMenuScopeKey) => CLButtonIcon.standard(
                Icons.add,
                onTap: widget.onPickFiles,
              ),
      ],
      pageBuilder: (context, quickMenuScopeKey) => Stack(
        key: parentKey,
        children: [
          Column(
            children: [
              Expanded(
                child: CLRefreshIndicator(
                  onRefresh: isSelectionMode ? null : widget.onRefresh,
                  key: ValueKey('${widget.tagPrefix} Refresh'),
                  child: ListView.builder(
                    //key: ValueKey(widget.galleryMap),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: widget.galleryMap.length,
                    itemBuilder: (BuildContext context, int groupIndex) {
                      final gallery = widget.galleryMap[groupIndex];
                      final labelWidget = gallery.label == null
                          ? null
                          : CLText.large(
                              gallery.label!,
                              textAlign: TextAlign.start,
                            );
                      return CLGrid<T>(
                        itemCount: gallery.items.length,
                        columns: widget.columns,
                        itemBuilder: (context, itemIndex) {
                          final itemWidget = widget.itemBuilder(
                            context,
                            gallery.items[itemIndex],
                            quickMenuScopeKey: quickMenuScopeKey,
                          );
                          if (!isSelectionMode) {
                            return itemWidget;
                          }
                          return SelectableItem(
                            isSelected:
                                selectionMap[groupIndex].items[itemIndex],
                            child: itemWidget,
                            onTap: () {
                              toggleSelection(groupIndex, itemIndex);

                              setState(() {});
                            },
                          );
                        },
                        header: gallery.label == null
                            ? null
                            : !isSelectionMode
                                ? labelWidget
                                : SelectableLabel(
                                    selectionMap:
                                        selectionMap[groupIndex].items,
                                    child: labelWidget ?? Container(),
                                    onSelect: ({required select}) {
                                      selectGroup(
                                        groupIndex,
                                        select: select,
                                      );
                                      setState(() {});
                                    },
                                  ),
                      );
                    },
                  ),
                ),
              ),
              if (isSelectionMode)
                SelectionCount(
                  selectionMap,
                  onSelectAll: ({required select}) {
                    selectAll(select: select);
                    setState(() {});
                  },
                ),
            ],
          ),
          if (hasSelection)
            DraggableMenu(
              key: ValueKey('${widget.tagPrefix} DraggableMenu'),
              parentKey: parentKey,
              child: Menu(
                menuItems: widget.selectionActions!(
                  context,
                  selectionMap.filterItems(widget.galleryMap),
                )
                    .insertOnDone(() {
                  selectAll(select: false);
                  isSelectionMode = false;
                  setState(() {});
                }),
              ),
            ),
        ],
      ),
    );
  }
}
