import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

import '../../draggable_menu/providers/menu_position.dart';
import '../../entity/models/cl_context_menu.dart';
import '../../entity/models/viewer_entity_mixin.dart';
import '../../gallery_grid_view/models/tab_identifier.dart';
import '../../gallery_grid_view/widgets/gallery_view.dart';
import '../../view_modifiers/search_filters/builders/get_filtered_media.dart';
import '../models/selector.dart';

import '../providers/select_mode.dart';
import '../providers/selector.dart';
import 'selectable_item.dart';
import 'selectable_label.dart';
import 'selection_count.dart';

class SelectionControl extends ConsumerWidget {
  const SelectionControl(
      {required this.tabIdentifier,
      required this.incoming,
      required this.itemBuilder,
      required this.labelBuilder,
      required this.bannersBuilder,
      required this.contextMenuOf,
      required this.onSelectionChanged,
      super.key,
      this.filtersDisabled = false,
      required this.whenEmpty});
  final TabIdentifier tabIdentifier;
  final List<ViewerEntityMixin> incoming;
  final Widget Function(
    BuildContext,
    ViewerEntityMixin,
  ) itemBuilder;
  final Widget? Function(
    BuildContext context,
    List<ViewerEntityGroup<ViewerEntityMixin>> galleryMap,
    ViewerEntityGroup<ViewerEntityMixin> gallery,
  ) labelBuilder;
  final List<Widget> Function(
    BuildContext context,
    List<ViewerEntityGroup<ViewerEntityMixin>> galleryMap,
  ) bannersBuilder;

  final CLContextMenu Function(BuildContext, List<ViewerEntityMixin>)?
      contextMenuOf;

  final void Function(List<ViewerEntityMixin>)? onSelectionChanged;

  final bool filtersDisabled;
  final Widget whenEmpty;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ProviderScope(
      overrides: [
        selectorProvider.overrideWith((ref) => SelectorNotifier(incoming)),
        menuPositionNotifierProvider
            .overrideWith((ref) => MenuPositionNotifier()),
      ],
      child: SelectionContol0(
        tabIdentifier: tabIdentifier,
        itemBuilder: itemBuilder,
        labelBuilder: labelBuilder,
        contextMenuOf: contextMenuOf,
        onSelectionChanged: onSelectionChanged,
        filtersDisabled: filtersDisabled,
        whenEmpty: whenEmpty,
      ),
    );
  }
}

class SelectionContol0 extends ConsumerWidget {
  const SelectionContol0(
      {required this.tabIdentifier,
      required this.itemBuilder,
      required this.labelBuilder,
      required this.contextMenuOf,
      required this.onSelectionChanged,
      super.key,
      required this.filtersDisabled,
      required this.whenEmpty});
  final TabIdentifier tabIdentifier;
  final bool filtersDisabled;
  final Widget whenEmpty;

  final Widget Function(
    BuildContext,
    ViewerEntityMixin,
  ) itemBuilder;
  final Widget? Function(
    BuildContext context,
    List<ViewerEntityGroup<ViewerEntityMixin>> galleryMap,
    ViewerEntityGroup<ViewerEntityMixin> gallery,
  ) labelBuilder;

  final CLContextMenu Function(BuildContext, List<ViewerEntityMixin>)?
      contextMenuOf;
  final void Function(List<ViewerEntityMixin>)? onSelectionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selector = ref.watch(selectorProvider);
    ref.listen(selectorProvider, (prev, curr) {
      onSelectionChanged?.call(curr.items.toList());
    });
    final incoming = selector.entities;

    return GetFilterredMedia(
      tabIdentifier: tabIdentifier,
      incoming: incoming,
      bannersBuilder: (context, galleryMap) {
        return [
          SelectionBanner(
            tabIdentifier: tabIdentifier,
            selector: selector,
            galleryMap: galleryMap,
          ),
        ];
      },
      disabled: filtersDisabled,
      builder: (
        List<ViewerEntityMixin> filterred, {
        required List<Widget> Function(
          BuildContext,
          List<ViewerEntityGroup<ViewerEntityMixin>>,
        ) bannersBuilder,
      }) {
        return CLGalleryGridView(
          tabIdentifier: tabIdentifier,
          incoming: filterred,
          bannersBuilder: bannersBuilder,
          labelBuilder: (context, galleryMap, gallery) {
            return SelectableLabel(
              tabIdentifier: tabIdentifier,
              labelBuilder: labelBuilder,
              gallery: gallery,
              galleryMap: galleryMap,
            );
          },
          itemBuilder: (
            context,
            item,
          ) {
            return SelectableItem(
              tabIdentifier: tabIdentifier,
              item: item,
              itemBuilder: itemBuilder,
            );
          },
          columns: 3,
          draggableMenuBuilder:
              selector.items.isNotEmpty && contextMenuOf != null
                  ? contextMenuOf!(context, selector.items.toList())
                      .draggableMenuBuilder(
                          context,
                          ref
                              .read(selectModeProvider(tabIdentifier).notifier)
                              .disable)
                  : null,
          whenEmpty: whenEmpty,
        );
      },
    );
  }
}

class SelectionBanner extends ConsumerWidget {
  const SelectionBanner({
    required this.selector,
    required this.tabIdentifier,
    super.key,
    this.galleryMap = const [],
  });
  final CLSelector selector;
  final List<ViewerEntityGroup> galleryMap;

  final TabIdentifier tabIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionMode = ref.watch(selectModeProvider(tabIdentifier));
    if (!selectionMode) {
      return SizedBox.shrink();
    }
    final allCount = selector.entities.length;
    final selectedInAllCount = selector.count;
    final currentItems = galleryMap.getEntities.toList();

    final selectionStatusOnVisible =
        selector.isSelected(currentItems) == SelectionStatus.selectedNone;
    final visibleCount = currentItems.length;
    final selectedInVisible = selector.selectedItems(currentItems);
    final selectedInVisibleCount = selectedInVisible.length;

    return SelectionCountView(
      buttonLabel: selectionStatusOnVisible ? 'Select All' : 'Select None',
      onPressed: () {
        ref.read(selectorProvider.notifier).updateSelection(currentItems);
      },
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedInAllCount > 0) ...[
            if (selectedInVisibleCount > 0)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text:
                          '$selectedInVisibleCount of $visibleCount selected.',
                    ),
                    TextSpan(
                      text: ' Clear ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () {
                          ref.read(selectorProvider.notifier).updateSelection(
                              selectedInVisible,
                              deselect: true);
                        },
                    ),
                  ],
                ),
              ),
            if (visibleCount < allCount)
              Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: 'Total: $selectedInAllCount of $allCount selected',
                    ),
                    TextSpan(
                      text: ' Clear ',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () => ref
                            .read(selectorProvider.notifier)
                            .updateSelection(null),
                    ),
                  ],
                ),
              ),
          ] else
            ShadButton.secondary(
              onPressed:
                  ref.read(selectModeProvider(tabIdentifier).notifier).disable,
              child: const Text(
                'Done',
              ),
            ),
        ],
      ),
    );
  }
}
