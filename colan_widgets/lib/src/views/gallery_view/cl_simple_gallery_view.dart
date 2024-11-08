import 'package:colan_widgets/src/extensions/ext_cl_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../basics/cl_button.dart';
import '../../basics/cl_pop_screen.dart';
import '../../basics/cl_refresh_indicator.dart';
import '../../models/cl_menu_item.dart';

import '../../theme/models/cl_icons.dart';
import '../appearance/keep_it_main_view.dart';
import '../draggable/draggable_menu.dart';
import '../draggable/menu.dart';
import '../draggable/menu_control.dart';
import 'cl_gallery_core.dart';
import 'model/gallery_group.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item);

class CLSimpleGalleryView<T> extends StatefulWidget {
  const CLSimpleGalleryView({
    required this.title,
    required this.identifier,
    required this.galleryMap,
    required this.emptyState,
    required this.itemBuilder,
    required this.columns,
    required this.backButton,
    required this.actionMenu,
    super.key,
    this.onRefresh,
    this.selectionActions,
  });

  final String title;
  final List<GalleryGroup<T>> galleryMap;
  final int columns;

  final Widget emptyState;
  final String identifier;
  final List<CLMenuItem> actionMenu;

  final Future<void> Function()? onRefresh;
  final List<CLMenuItem> Function(BuildContext context, List<T> selectedItems)?
      selectionActions;
  final ItemBuilder<T> itemBuilder;
  final Widget? backButton;

  @override
  State<CLSimpleGalleryView<T>> createState() => _CLSimpleGalleryViewState<T>();
}

class _CLSimpleGalleryViewState<T> extends State<CLSimpleGalleryView<T>> {
  final GlobalKey parentKey = GlobalKey();
  bool isSelectionMode = false;
  List<T> selectedItems = [];
  @override
  Widget build(BuildContext context) {
    if (widget.galleryMap.isEmpty) {
      return KeepItMainView(
        key: ValueKey('KeepItMainView ${widget.identifier}'),
        title: widget.title,
        backButton: CLPopScreen.canPop(context)
            ? CLButtonIcon.small(
                clIcons.pagePop,
                onTap: () => CLPopScreen.onPop(context),
              )
            : null,
        actionsBuilder: widget.actionMenu
            .map(
              (e) => (_) => CLButtonIcon.small(
                    e.icon,
                    onTap: e.onTap,
                  ),
            )
            .toList(),
        pageBuilder: (context) => widget.emptyState,
      );
    } else {
      return ProviderScope(
        overrides: [
          menuControlNotifierProvider
              .overrideWith((ref) => MenuControlNotifier()),
        ],
        child: KeepItMainView(
          title: widget.title,
          backButton: widget.backButton,
          actionsBuilder: [
            if (widget.selectionActions != null)
              (context) => CLButtonText.small(
                    isSelectionMode ? 'Done' : 'Select',
                    onTap: () {
                      setState(() {
                        isSelectionMode = !isSelectionMode;
                      });
                    },
                  ),
            if (!isSelectionMode)
              (context) => Row(
                    children: widget.actionMenu
                        .map(
                          (e) => CLButtonIcon.small(
                            e.icon,
                            onTap: e.onTap,
                          ),
                        )
                        .toList(),
                  ),
          ],
          pageBuilder: (context) {
            return Stack(
              key: parentKey,
              children: [
                CLRefreshIndicator(
                  onRefresh: isSelectionMode ? null : widget.onRefresh,
                  key: ValueKey('${widget.identifier} Refresh'),
                  child: CLGalleryCore(
                    key: ValueKey(widget.galleryMap),
                    items: widget.galleryMap,
                    itemBuilder: (context, item) {
                      return widget.itemBuilder(
                        context,
                        item,
                      );
                    },
                    columns: widget.columns,
                    keepSelected: false,
                    onSelectionChanged: isSelectionMode
                        ? (List<T> items) {
                            selectedItems = items;
                            setState(() {});
                          }
                        : null,
                  ),
                ),
                if (isSelectionMode && selectedItems.isNotEmpty)
                  ActionsDraggableMenu<T>(
                    items: selectedItems,
                    tagPrefix: widget.identifier,
                    onDone: () {
                      isSelectionMode = false;
                      //onDone();
                      if (mounted) {
                        setState(() {});
                      }
                    },
                    selectionActions: widget.selectionActions,
                    parentKey: parentKey,
                  ),
              ],
            );
          },
        ),
      );
    }
  }
}

class ActionsDraggableMenu<T> extends StatelessWidget {
  const ActionsDraggableMenu({
    required this.tagPrefix,
    required this.parentKey,
    required this.selectionActions,
    required this.items,
    required this.onDone,
    super.key,
  });
  final String tagPrefix;
  final GlobalKey parentKey;
  final List<CLMenuItem> Function(BuildContext context, List<T> selectedItems)?
      selectionActions;
  final VoidCallback onDone;
  final List<T> items;
  @override
  Widget build(BuildContext context) {
    return DraggableMenu(
      key: ValueKey('$tagPrefix DraggableMenu'),
      parentKey: parentKey,
      child: Menu(
        menuItems: selectionActions!(
          context,
          items,
        ).insertOnDone(onDone),
      ),
    );
  }
}

class CLSimpleItemsSelector<T> extends StatefulWidget {
  const CLSimpleItemsSelector({
    required this.identifier,
    required this.galleryMap,
    required this.emptyState,
    required this.itemBuilder,
    required this.columns,
    required this.onSelectionChanged,
    required this.keepSelected,
    super.key,
  });

  final List<GalleryGroup<T>> galleryMap;
  final int columns;

  final Widget emptyState;
  final String identifier;

  final Widget Function(
    BuildContext context,
    T item,
  ) itemBuilder;

  final void Function(List<T>) onSelectionChanged;
  final bool keepSelected;

  @override
  State<CLSimpleItemsSelector<T>> createState() =>
      CLSimpleItemsSelectorState<T>();
}

class CLSimpleItemsSelectorState<T> extends State<CLSimpleItemsSelector<T>> {
  final GlobalKey parentKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    if (widget.galleryMap.isEmpty) {
      return widget.emptyState;
    } else {
      return CLGalleryCore1(
        key: ValueKey(widget.galleryMap),
        items: widget.galleryMap,
        itemBuilder: (context, item) {
          return widget.itemBuilder(
            context,
            item,
          );
        },
        columns: widget.columns,
        onSelectionChanged: widget.onSelectionChanged,
        keepSelected: widget.keepSelected,
      );
    }
  }
}
