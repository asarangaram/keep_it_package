import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../draggable/draggable_menu.dart';
import '../draggable/menu.dart';
import '../draggable/menu_control.dart';

@immutable
class GalleryGroup<T> {
  const GalleryGroup(this.items, {this.label});
  final String? label;
  final List<T> items;
}

class GalleryGroupMutable<T> {
  const GalleryGroupMutable(this.items, {this.label});
  final String? label;
  final List<T> items;
}

extension ExtListGalleryGroupMutable<T> on List<GalleryGroupMutable<T>> {
  int get totalCount => fold<int>(
        0,
        (previousValue, element) => previousValue + element.items.length,
      );
}

extension IterableExtensions<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

extension IterableIndexedExtensions<E> on Iterable<E> {
  void forEachIndexed(void Function(int index, E element) action) {
    var index = 0;
    for (final element in this) {
      action(index, element);
      index++;
    }
  }
}

extension ExtListGalleryGroupMutableBool<bool>
    on List<GalleryGroupMutable<bool>> {
  int get trueCount => fold<int>(
        0,
        (previousValue, element) =>
            previousValue +
            element.items.where((element) => element == true).length,
      );

  List<T> filterItems<T>(List<GalleryGroup<T>> originalList) {
    final items = <T>[];
    for (final group in originalList) {
      final boolGroup = firstWhereOrNull(
        (mutableGroup) => mutableGroup.label == group.label,
      );
      boolGroup?.items.forEachIndexed((index, flag) {
        if (flag == true) {
          items.add(group.items[index]);
        }
      });
    }
    return items;
  }
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
    this.selectionActions,
  });

  final String title;
  final List<GalleryGroup<T>> galleryMap;
  final int columns;

  final Widget emptyState;
  final String tagPrefix;
  final void Function()? onPickFiles;
  final void Function()? onPop;
  final Future<void> Function()? onRefresh;
  final List<CLMenuItem> Function(BuildContext context)? selectionActions;

  final Widget Function(
    BuildContext context,
    T item, {
    required GlobalKey<State<StatefulWidget>> quickMenuScopeKey,
  }) itemBuilder;

  @override
  Widget build(BuildContext context) {
    if (galleryMap.isEmpty) {
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
            child: emptyState,
          );
        },
      );
    } else {
      return ProviderScope(
        overrides: [
          menuControlNotifierProvider.overrideWith((ref) {
            return MenuControlNotifier();
          }),
        ],
        child: CLSimpleGalleryView0(
          title: title,
          onPickFiles: onPickFiles,
          onPop: onPop,
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
    required this.onPop,
    required this.onRefresh,
    required this.selectionActions,
    super.key,
  });

  final String title;
  final List<GalleryGroup<T>> galleryMap;
  final int columns;

  final String tagPrefix;
  final void Function()? onPickFiles;
  final void Function()? onPop;
  final Future<void> Function()? onRefresh;

  final Widget Function(
    BuildContext context,
    T item, {
    required GlobalKey<State<StatefulWidget>> quickMenuScopeKey,
  }) itemBuilder;
  final List<CLMenuItem> Function(BuildContext context)? selectionActions;

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

  @override
  Widget build(BuildContext context) {
    return KeepItMainView(
      title: widget.title,
      onPop: widget.onPop,
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
      pageBuilder: (context, quickMenuScopeKey) {
        return Stack(
          key: parentKey,
          children: [
            Column(
              children: [
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: widget.onRefresh ?? () async {},
                    key: ValueKey('${widget.tagPrefix} Refresh'),
                    child: ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: widget.galleryMap.length,
                      itemBuilder: (BuildContext context, int index) {
                        return CLGrid<T>(
                          itemCount: widget.galleryMap[index].items.length,
                          columns: widget.columns,
                          itemBuilder: (context, groupIndex) {
                            final media =
                                widget.galleryMap[index].items[groupIndex];
                            final isSelected =
                                selectionMap[index].items[groupIndex];
                            return Stack(
                              children: [
                                widget.itemBuilder(
                                  context,
                                  media,
                                  quickMenuScopeKey: quickMenuScopeKey,
                                ),
                                if (isSelectionMode)
                                  Positioned.fill(
                                    child: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          selectionMap[index]
                                              .items[groupIndex] = !isSelected;
                                        });
                                      },
                                      child: SizedBox.expand(
                                        child: Container(
                                          decoration: isSelected
                                              ? BoxDecoration(
                                                  border: Border.all(
                                                    color: const Color.fromARGB(
                                                      255,
                                                      0x08,
                                                      0xFF,
                                                      0x08,
                                                    ),
                                                  ),
                                                )
                                              : BoxDecoration(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .surface
                                                      .withAlpha(128),
                                                ),
                                          child: isSelected
                                              ? Center(
                                                  child: FractionallySizedBox(
                                                    widthFactor: 0.3,
                                                    heightFactor: 0.3,
                                                    child: FittedBox(
                                                      child: DecoratedBox(
                                                        decoration:
                                                            BoxDecoration(
                                                          shape:
                                                              BoxShape.circle,
                                                          color: Theme.of(
                                                            context,
                                                          )
                                                              .colorScheme
                                                              .onBackground
                                                              .withAlpha(
                                                                192,
                                                              ), // Color for the circular container
                                                        ),
                                                        child: CLIcon.veryLarge(
                                                          Icons.check,
                                                          color: Theme.of(
                                                            context,
                                                          )
                                                              .colorScheme
                                                              .background
                                                              .withAlpha(192),
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                )
                                              : null,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                          header: widget.galleryMap[index].label == null
                              ? null
                              : Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  child: CLText.large(
                                    widget.galleryMap[index].label!,
                                    textAlign: TextAlign.start,
                                  ),
                                ),
                        );
                      },
                    ),
                  ),
                ),
                if (widget.selectionActions != null &&
                    isSelectionMode &&
                    selectionMap.trueCount > 0)
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primaryContainer,
                      //borderRadius: BorderRadius.circular(15),
                      /* border: Border.all(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ), */
                      boxShadow: const [
                        BoxShadow(
                          color: Color.fromARGB(
                            128 + 64,
                            128 + 64,
                            128 + 64,
                            128 + 64,
                          ),
                          blurRadius: 20, // soften the shadow
                          offset: Offset(
                            10, // Move to right 10  horizontally
                            5, // Move to bottom 10 Vertically
                          ),
                        ),
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          CLText.large(
                            ' ${selectionMap.trueCount} '
                            'of ${selectionMap.totalCount} selected',
                            color: Theme.of(context)
                                .colorScheme
                                .onPrimaryContainer,
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            child: const CLText.standard('Select All'),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
            if (widget.selectionActions != null &&
                isSelectionMode &&
                selectionMap.trueCount > 0)
              DraggableMenu(
                key: const ValueKey('DraggableMenu'),
                parentKey: parentKey,
                child: Menu(
                  menuItems: widget.selectionActions!(context),
                ),
              ),
          ],
        );
      },
    );
  }
}

class TopStripWithButtons extends StatelessWidget {
  const TopStripWithButtons({required this.buttons, super.key});
  final List<Widget> buttons;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 8,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              for (var i = 0; i < buttons.length - 1; i++)
                Padding(
                  padding: const EdgeInsets.only(right: 32),
                  child: buttons[i],
                ),
              buttons.last,
            ],
          ),
        ),
      ),
    );
  }
}

class TopStripContainer extends StatelessWidget {
  const TopStripContainer({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.surface,
            Theme.of(context).colorScheme.surface.withAlpha(192),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: child,
    );
  }
}

class CLGrid<T> extends StatelessWidget {
  const CLGrid({
    required this.itemCount,
    required this.itemBuilder,
    required this.columns,
    this.additionalItems,
    this.rows,
    this.physics = const NeverScrollableScrollPhysics(),
    this.header,
    this.footer,
    this.crossAxisSpacing = 2.0,
    this.mainAxisSpacing = 2.0,
    super.key,
  });
  final int itemCount;
  final List<Widget>? additionalItems;
  final int columns;
  final int? rows;
  final ScrollPhysics? physics;
  final Widget? header;
  final Widget? footer;
  final double crossAxisSpacing;
  final double mainAxisSpacing;

  final Widget Function(BuildContext context, int index) itemBuilder;

  @override
  Widget build(BuildContext context) {
    final int limitCount;
    final additionaItemsCount = additionalItems?.length ?? 0;
    final totalItems = itemCount + additionaItemsCount;
    if (rows == null) {
      limitCount = itemCount;
    } else {
      limitCount = min(totalItems, rows! * columns) - additionaItemsCount;
    }
    if (itemCount == 0) {
      return const SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null) header!,
        GridView.builder(
          padding: const EdgeInsets.only(top: 2),
          shrinkWrap: true,
          physics: physics,
          itemBuilder: (context, index) {
            if (index >= limitCount) {
              if (index - limitCount < additionalItems!.length) {
                return additionalItems![index - limitCount];
              }
              /* return  */
            }
            if (index >= itemCount) {
              return Container();
            }

            return itemBuilder(context, index);
          },
          itemCount: limitCount + additionaItemsCount,
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: crossAxisSpacing,
            mainAxisSpacing: mainAxisSpacing,
          ),
        ),
        if (footer != null) footer!,
      ],
    );
  }
}
