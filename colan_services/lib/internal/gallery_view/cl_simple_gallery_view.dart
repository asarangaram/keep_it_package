import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../draggable/draggable_menu.dart';
import '../draggable/menu.dart';
import '../draggable/menu_control.dart';
import 'cl_gallery_core.dart';
import 'providers/selector.dart';

typedef ItemBuilder = Widget Function(BuildContext context, CLEntity item);

class CLSimpleGalleryView<T> extends StatefulWidget {
  const CLSimpleGalleryView({
    required this.identifier,
    required this.items,
    required this.galleryMap,
    required this.itemBuilder,
    required this.columns,
    this.selectionActions,
    super.key,
  });

  final String identifier;
  final List<CLEntity> items;
  final ItemBuilder itemBuilder;
  final int columns;

  final List<CLMenuItem> Function(BuildContext context, List<T> selectedItems)?
      selectionActions;

  final List<GalleryGroupCLEntity> galleryMap;
  @override
  State<CLSimpleGalleryView<T>> createState() => _CLSimpleGalleryViewState<T>();
}

class _CLSimpleGalleryViewState<T> extends State<CLSimpleGalleryView<T>> {
  final GlobalKey parentKey = GlobalKey();

  @override
  void initState() {
    if (widget.items.isEmpty) {
      throw Exception("galleryMap can't be empty");
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        selectorProvider.overrideWith((ref) => SelectorNotifier(widget.items)),
        menuControlNotifierProvider
            .overrideWith((ref) => MenuControlNotifier()),
      ],
      child: Stack(
        key: parentKey,
        children: [
          CLGalleryCore(
            parentIdentifier: widget.identifier,
            key: ValueKey(widget.galleryMap),
            galleryMap: widget.galleryMap,
            itemBuilder: (context, item) {
              return widget.itemBuilder(
                context,
                item,
              );
            },
            columns: widget.columns,
          ),
          /* if (isSelectionMode && selectedItems.isNotEmpty)
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
              ), */
        ],
      ),
    );
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
