import 'package:colan_widgets/src/extensions/ext_cl_menu_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../basics/cl_button.dart';
import '../../basics/cl_refresh_indicator.dart';
import '../../models/cl_menu_item.dart';
import '../../models/typedefs.dart';
import '../appearance/keep_it_main_view.dart';
import '../draggable/draggable_menu.dart';
import '../draggable/menu.dart';
import '../draggable/menu_control.dart';
import 'cl_gallery_core.dart';
import 'model/gallery_group.dart';

class CLSimpleGalleryView<T> extends StatefulWidget {
  const CLSimpleGalleryView({
    required this.title,
    required this.identifier,
    required this.galleryMap,
    required this.emptyState,
    required this.itemBuilder,
    required this.columns,
    this.onPickFiles,
    this.onCameraCapture,
    super.key,
    this.onRefresh,
    this.selectionActions,
  });

  final String title;
  final List<GalleryGroup<T>> galleryMap;
  final int columns;

  final Widget emptyState;
  final String identifier;
  final void Function(BuildContext context)? onPickFiles;
  final void Function()? onCameraCapture;

  final Future<void> Function()? onRefresh;
  final List<CLMenuItem> Function(BuildContext context, List<T> selectedItems)?
      selectionActions;
  final ItemBuilder<T> itemBuilder;

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
        actionsBuilder: [
          if (widget.onCameraCapture != null)
            (context, quickMenuScopeKey) => CLButtonIcon.small(
                  MdiIcons.camera,
                  onTap: widget.onCameraCapture,
                ),
          if (widget.onPickFiles != null)
            (context, quickMenuScopeKey) => CLButtonIcon.standard(
                  Icons.add,
                  onTap: () => widget.onPickFiles?.call(context),
                ),
        ],
        pageBuilder: (context, quickMenuScopeKey) => widget.emptyState,
      );
    } else {
      return ProviderScope(
        overrides: [
          menuControlNotifierProvider
              .overrideWith((ref) => MenuControlNotifier()),
        ],
        child: KeepItMainView(
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
            if (!isSelectionMode)
              (context, quickMenuScopeKey) => Row(
                    children: [
                      if (widget.onPickFiles != null)
                        CLButtonIcon.standard(
                          Icons.add,
                          onTap: () => widget.onPickFiles?.call(context),
                        ),
                      if (widget.onCameraCapture != null)
                        CLButtonIcon.small(
                          MdiIcons.camera,
                          onTap: widget.onCameraCapture,
                        ),
                    ],
                  ),
          ],
          pageBuilder: (context, quickMenuScopeKey) {
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
                        quickMenuScopeKey: quickMenuScopeKey,
                      );
                    },
                    columns: widget.columns,
                    onSelectionChanged: isSelectionMode
                        ? (List<T> items) {
                            selectedItems = items;
                            setState(() {});
                          }
                        : null,
                  ),
                ),
                if (selectedItems.isNotEmpty)
                  ActionsDraggableMenu<T>(
                    items: selectedItems,
                    tagPrefix: widget.identifier,
                    onDone: () {
                      //isSelectionMode = false;
                      //onDone();
                      //setState(() {});
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
