import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:shadcn_ui/shadcn_ui.dart';

import '../../draggable_menu/providers/menu_position.dart';
import '../../entity/models/cl_context_menu.dart';
import '../../entity/models/viewer_entity_mixin.dart';
import '../../gallery_grid_view/models/tab_identifier.dart';
import '../../gallery_grid_view/providers/tap_state.dart';
import '../models/selector.dart';

import '../providers/select_mode.dart';
import '../providers/selector.dart';
import 'selectable_item.dart';
import 'selectable_label.dart';
import 'selection_count.dart';

class SelectionControl extends ConsumerWidget {
  const SelectionControl({
    required this.viewIdentifier,
    required this.incoming,
    required this.builder,
    required this.itemBuilder,
    required this.labelBuilder,
    required this.bannersBuilder,
    required this.contextMenuOf,
    required this.onSelectionChanged,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
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
  final Widget Function({
    required List<ViewerEntityMixin> items,
    required Widget Function(
      BuildContext,
      ViewerEntityMixin,
    ) itemBuilder,
    required Widget? Function(
      BuildContext context,
      List<ViewerEntityGroup<ViewerEntityMixin>> galleryMap,
      ViewerEntityGroup<ViewerEntityMixin> gallery,
    ) labelBuilder,
    required List<Widget> Function(
      BuildContext context,
      List<ViewerEntityGroup<ViewerEntityMixin>> galleryMap,
    ) bannersBuilder,
    Widget Function(
      BuildContext, {
      required GlobalKey<State<StatefulWidget>> parentKey,
    })? draggableMenuBuilder,
  }) builder;
  final CLContextMenu Function(BuildContext, List<ViewerEntityMixin>)?
      contextMenuOf;

  final void Function(List<ViewerEntityMixin>)? onSelectionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentTab = ref.watch(currTabProvider(viewIdentifier));
    final tabIdentifier =
        TabIdentifier(view: viewIdentifier, tabId: currentTab);
    return ProviderScope(
      overrides: [
        selectorProvider.overrideWith((ref) => SelectorNotifier(incoming)),
        menuPositionNotifierProvider
            .overrideWith((ref) => MenuPositionNotifier()),
      ],
      child: SelectionContol0(
        tabIdentifier: tabIdentifier,
        builder: builder,
        itemBuilder: itemBuilder,
        labelBuilder: labelBuilder,
        contextMenuOf: contextMenuOf,
        onSelectionChanged: onSelectionChanged,
      ),
    );
  }
}

class SelectionContol0 extends ConsumerWidget {
  const SelectionContol0({
    required this.tabIdentifier,
    required this.builder,
    required this.itemBuilder,
    required this.labelBuilder,
    required this.contextMenuOf,
    required this.onSelectionChanged,
    super.key,
  });
  final TabIdentifier tabIdentifier;

  final Widget Function(
    BuildContext,
    ViewerEntityMixin,
  ) itemBuilder;
  final Widget? Function(
    BuildContext context,
    List<ViewerEntityGroup<ViewerEntityMixin>> galleryMap,
    ViewerEntityGroup<ViewerEntityMixin> gallery,
  ) labelBuilder;
  final Widget Function({
    required List<ViewerEntityMixin> items,
    required Widget Function(
      BuildContext,
      ViewerEntityMixin,
    ) itemBuilder,
    required Widget? Function(
      BuildContext context,
      List<ViewerEntityGroup<ViewerEntityMixin>> galleryMap,
      ViewerEntityGroup<ViewerEntityMixin> gallery,
    ) labelBuilder,
    required List<Widget> Function(
      BuildContext context,
      List<ViewerEntityGroup<ViewerEntityMixin>> galleryMap,
    ) bannersBuilder,
    DraggableMenuBuilderType? draggableMenuBuilder,
  }) builder;

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

    return builder(
      items: incoming,
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
      labelBuilder: (context, galleryMap, gallery) {
        return SelectableLabel(
          labelBuilder: labelBuilder,
          gallery: gallery,
          galleryMap: galleryMap,
        );
      },
      bannersBuilder: (context, galleryMap) {
        return [
          SelectionBanner(
            tabIdentifier: tabIdentifier,
            selector: selector,
            galleryMap: galleryMap,
          ),
        ];
      },
      draggableMenuBuilder: selector.items.isNotEmpty && contextMenuOf != null
          ? contextMenuOf!(context, selector.items.toList())
              .draggableMenuBuilder(context,
                  ref.read(selectModeProvider(tabIdentifier).notifier).disable)
          : null,
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
              onPressed: ref
                  .read(selectModeProvider(tabIdentifier).notifier)
                  .disable(),
              child: const Text(
                'Done',
              ),
            ),
        ],
      ),
    );
  }
}
