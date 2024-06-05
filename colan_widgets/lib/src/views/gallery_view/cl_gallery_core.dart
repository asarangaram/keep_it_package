import 'package:flutter/material.dart';

import '../../basics/cl_text.dart';
import 'model/gallery_group.dart';
import 'selection/selectable_item.dart';
import 'selection/selectable_label.dart';
import 'selection/selection_count.dart';
import 'widgets/cl_grid.dart';

class CLGalleryCore<T> extends StatelessWidget {
  const CLGalleryCore({
    required this.items,
    required this.itemBuilder,
    required this.columns,
    required this.onSelectionChanged,
    super.key,
  });
  final List<GalleryGroup<T>> items;
  final Widget Function(
    BuildContext context,
    T item,
  ) itemBuilder;

  final int columns;

  final void Function(List<T> items)? onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    if (onSelectionChanged == null) {
      return CLGalleryCore0(
        items: items,
        itemBuilder: itemBuilder,
        columns: columns,
      );
    }
    return CLGalleryCore1(
      items: items,
      itemBuilder: itemBuilder,
      columns: columns,
      onSelectionChanged: onSelectionChanged!,
    );
  }
}

class CLGalleryCore1<T> extends StatefulWidget {
  const CLGalleryCore1({
    required this.items,
    required this.itemBuilder,
    required this.columns,
    required this.onSelectionChanged,
    super.key,
  });

  final List<GalleryGroup<T>> items;
  final Widget Function(
    BuildContext context,
    T item,
  ) itemBuilder;

  final int columns;

  final void Function(List<T> items) onSelectionChanged;

  @override
  State<CLGalleryCore1<T>> createState() => _CLGalleryCoreState1<T>();
}

class _CLGalleryCoreState1<T> extends State<CLGalleryCore1<T>> {
  late List<GalleryGroupMutable<bool>> selectionMap;

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    selectionMap = createBooleanList(widget.items);
    super.didChangeDependencies();
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
    widget.onSelectionChanged.call(selectionMap.filterItems(widget.items));
  }

  void selectGroup(int groupIndex, {required bool select}) {
    final group = selectionMap[groupIndex];

    for (var i = 0; i < group.items.length; i++) {
      group.items[i] = select;
    }
    widget.onSelectionChanged.call(selectionMap.filterItems(widget.items));
  }

  void selectAll({required bool select}) {
    for (var g = 0; g < selectionMap.length; g++) {
      final group = selectionMap[g];

      for (var i = 0; i < group.items.length; i++) {
        group.items[i] = select;
      }
    }
    widget.onSelectionChanged.call(selectionMap.filterItems(widget.items));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView.builder(
            //key: ValueKey(widget.galleryMap),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: widget.items.length,
            itemBuilder: (BuildContext context, int groupIndex) {
              final gallery = widget.items[groupIndex];
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
                  );

                  return SelectableItem(
                    isSelected: selectionMap[groupIndex].items[itemIndex],
                    child: itemWidget,
                    onTap: () {
                      toggleSelection(groupIndex, itemIndex);

                      setState(() {});
                    },
                  );
                },
                header: gallery.label == null
                    ? null
                    : SelectableLabel(
                        selectionMap: selectionMap[groupIndex].items,
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
        SelectionCount(
          selectionMap,
          onSelectAll: ({required select}) {
            selectAll(select: select);
            setState(() {});
          },
        ),
      ],
    );
  }
}

class CLGalleryCore0<T> extends StatelessWidget {
  const CLGalleryCore0({
    required this.items,
    required this.itemBuilder,
    required this.columns,
    super.key,
  });

  final List<GalleryGroup<T>> items;
  final Widget Function(
    BuildContext context,
    T item,
  ) itemBuilder;

  final int columns;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (BuildContext context, int groupIndex) {
        final gallery = items[groupIndex];
        final labelWidget = gallery.label == null
            ? null
            : CLText.large(
                gallery.label!,
                textAlign: TextAlign.start,
              );
        return CLGrid<T>(
          itemCount: gallery.items.length,
          columns: columns,
          itemBuilder: (context, itemIndex) {
            final itemWidget = itemBuilder(
              context,
              gallery.items[itemIndex],
            );

            return itemWidget;
          },
          header: gallery.label == null ? null : labelWidget,
        );
      },
    );
  }
}
