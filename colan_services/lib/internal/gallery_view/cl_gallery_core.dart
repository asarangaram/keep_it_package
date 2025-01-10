import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'model/selector.dart';
import 'providers/selector.dart';
import 'selection/selectable_item.dart';
import 'selection/selectable_label.dart';
import 'selection/selection_count.dart';
import 'widgets/cl_grid.dart';

class CLGalleryCore<T extends CLEntity> extends ConsumerWidget {
  const CLGalleryCore({
    required this.parentIdentifier,
    required this.galleryMap,
    required this.itemBuilder,
    required this.columns,
    required this.keepSelected,
    super.key,
  });

  final String parentIdentifier;
  final List<GalleryGroupCLEntity<T>> galleryMap;
  final Widget Function(
    BuildContext context,
    T item,
  ) itemBuilder;

  final int columns;
  final bool keepSelected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectMode = ref.watch(selectModeProvider(parentIdentifier));
    if (!selectMode) {
      return CLGalleryCore0(
        items: galleryMap,
        itemBuilder: itemBuilder,
        columns: columns,
      );
    }
    return CLGalleryCore1(
      galleryMap: galleryMap,
      itemBuilder: itemBuilder,
      columns: columns,
      keepSelected: keepSelected,
    );
  }
}

class CLGalleryCore1<T extends CLEntity> extends ConsumerStatefulWidget {
  const CLGalleryCore1({
    required this.galleryMap,
    required this.itemBuilder,
    required this.columns,
    required this.keepSelected,
    super.key,
  });

  final List<GalleryGroupCLEntity<T>> galleryMap;
  final Widget Function(
    BuildContext context,
    T item,
  ) itemBuilder;

  final int columns;

  final bool keepSelected;

  @override
  ConsumerState<CLGalleryCore1<T>> createState() => _CLGalleryCoreState1<T>();
}

class _CLGalleryCoreState1<T extends CLEntity>
    extends ConsumerState<CLGalleryCore1<T>> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final selector = ref.watch(selectorProvider);

    return Column(
      children: [
        SelectionCount(
          groupEntities: widget.galleryMap,
        ),
        Expanded(
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
                  );

                  return SelectableItem(
                    isSelected:
                        selector.isSelected([gallery.items[itemIndex]]) !=
                            SelectionStatus.selectedNone,
                    onTap: () {
                      ref
                          .read(selectorProvider.notifier)
                          .toggle([gallery.items[itemIndex]]);
                    },
                    child: itemWidget,
                  );
                },
                header: gallery.label == null
                    ? null
                    : SelectableLabel(
                        selectionStatus: selector.isSelected(
                          widget.galleryMap
                              .getEntitiesByGroup(gallery.groupIdentifier)
                              .toList(),
                        ),
                        onSelect: () {
                          ref.read(selectorProvider.notifier).toggle(
                                widget.galleryMap
                                    .getEntitiesByGroup(gallery.groupIdentifier)
                                    .toList(),
                              );
                        },
                        child: labelWidget ?? Container(),
                      ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class CLGalleryCore0<T extends CLEntity> extends StatelessWidget {
  const CLGalleryCore0({
    required this.items,
    required this.itemBuilder,
    required this.columns,
    super.key,
  });

  final List<GalleryGroupCLEntity<T>> items;
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
