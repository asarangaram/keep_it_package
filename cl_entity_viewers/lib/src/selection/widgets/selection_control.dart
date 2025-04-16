import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

import '../../entity/models/cl_context_menu.dart';
import '../../entity/models/viewer_entity_mixin.dart';
import '../../gallery_grid_view/models/tab_identifier.dart';
import '../../gallery_grid_view/widgets/gallery_view.dart';

import '../../view_modifiers/search_filters/providers/media_filters.dart';
import '../models/selector.dart';

import '../providers/select_mode.dart';
import '../providers/selector.dart';
import 'selectable_item.dart';
import 'selectable_label.dart';
import 'selection_count.dart';

class SelectionContol extends ConsumerWidget {
  const SelectionContol(
      {required this.tabIdentifier,
      required this.itemBuilder,
      required this.contextMenuBuilder,
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

  final CLContextMenu Function(BuildContext, List<ViewerEntityMixin>)?
      contextMenuBuilder;
  final void Function(List<ViewerEntityMixin>)? onSelectionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selector = ref.watch(selectorProvider);
    ref.listen(selectorProvider, (prev, curr) {
      onSelectionChanged?.call(curr.items.toList());
    });
    final incoming = selector.entities;

    final filterred =
        ref.watch(filterredMediaProvider(MapEntry(tabIdentifier, incoming)));

    /* return MediaViewService1.pageView(
          media: filterred.map((e) => e as StoreEntity).toList(),
          parentIdentifier: viewIdentifier.toString(),
          initialMediaIndex:
              filterred.indexWhere((e) => e.id == initialMediaIndex),
          errorBuilder: errorBuilder,
          loadingBuilder: () => CLLoader.widget(
            debugMessage: 'MediaViewService.pageView',
          ),
        ); */

    return CLRawGalleryGridView(
      tabIdentifier: tabIdentifier,
      incoming: filterred,
      bannersBuilder: (context, galleryMap) {
        return [
          if (incoming.isNotEmpty && filterred.length < incoming.length)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Container(
                color: ShadTheme.of(context).colorScheme.mutedForeground,
                padding: const EdgeInsets.symmetric(vertical: 2),
                child: Center(
                  child: Text(
                    ' ${filterred.length} out of '
                    '${incoming.length} matches',
                    style: ShadTheme.of(context).textTheme.small.copyWith(
                        color: ShadTheme.of(context).colorScheme.muted),
                  ),
                ),
              ),
            ),
          if (incoming.isNotEmpty)
            SelectionBanner(
              tabIdentifier: tabIdentifier,
              selector: selector,
              galleryMap: galleryMap,
            ),
        ];
      },
      labelBuilder: (context, galleryMap, gallery) => SelectableLabel(
        tabIdentifier: tabIdentifier,
        gallery: gallery,
        galleryMap: galleryMap,
      ),
      itemBuilder: (context, item) => SelectableItem(
        tabIdentifier: tabIdentifier,
        item: item,
        itemBuilder: itemBuilder,
      ),
      columns: 3,
      draggableMenuBuilder: selector.items.isNotEmpty &&
              contextMenuBuilder != null
          ? contextMenuBuilder!(context, selector.items.toList())
              .draggableMenuBuilder(context,
                  ref.read(selectModeProvider(tabIdentifier).notifier).disable)
          : null,
      whenEmpty: whenEmpty,
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
