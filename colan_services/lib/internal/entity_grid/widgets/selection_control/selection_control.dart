import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:keep_it_state/keep_it_state.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:store/store.dart';

import '../../../../builders/get_selection_control.dart';
import '../../../draggable_menu/widgets/actions_draggable_menu.dart';

import '../../builders/get_selection_mode.dart';
import 'widgets/selectable_item.dart';
import 'widgets/selectable_label.dart';
import 'widgets/selection_count.dart';

class SelectionControl extends ConsumerWidget {
  const SelectionControl({
    required this.viewIdentifier,
    required this.incoming,
    required this.builder,
    required this.itemBuilder,
    required this.labelBuilder,
    required this.bannersBuilder,
    required this.selectionActionsBuilder,
    required this.onSelectionChanged,
    super.key,
  });
  final ViewIdentifier viewIdentifier;
  final List<CLEntity> incoming;
  final Widget Function(BuildContext, CLEntity) itemBuilder;
  final Widget? Function(
    BuildContext context,
    List<GalleryGroupCLEntity<CLEntity>> galleryMap,
    GalleryGroupCLEntity<CLEntity> gallery,
  ) labelBuilder;
  final List<Widget> Function(
    BuildContext context,
    List<GalleryGroupCLEntity<CLEntity>> galleryMap,
  ) bannersBuilder;
  final Widget Function({
    required List<CLEntity> items,
    required Widget Function(BuildContext, CLEntity) itemBuilder,
    required Widget? Function(
      BuildContext context,
      List<GalleryGroupCLEntity<CLEntity>> galleryMap,
      GalleryGroupCLEntity<CLEntity> gallery,
    ) labelBuilder,
    required List<Widget> Function(
      BuildContext context,
      List<GalleryGroupCLEntity<CLEntity>> galleryMap,
    ) bannersBuilder,
  }) builder;

  final List<CLMenuItem> Function(BuildContext, List<CLEntity>)?
      selectionActionsBuilder;
  final void Function(List<CLEntity>)? onSelectionChanged;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetSelectionMode(
      viewIdentifier: viewIdentifier,
      builder: ({
        required onUpdateSelectionmode,
        required tabIdentifier,
        required selectionMode,
      }) {
        if (!selectionMode) {
          return builder(
            items: incoming,
            itemBuilder: itemBuilder,
            labelBuilder: labelBuilder,
            bannersBuilder: bannersBuilder,
          );
        }
        return GetSelectionControl(
          incoming: incoming,
          onSelectionChanged: onSelectionChanged,
          builder: (selector, {required onUpdateSelection}) {
            return SelectionContol0(
              tabIdentifier: tabIdentifier,
              selector: selector,
              builder: builder,
              itemBuilder: itemBuilder,
              labelBuilder: labelBuilder,
              selectionActionsBuilder: selectionActionsBuilder,
              onSelectionChanged: onSelectionChanged,
              onUpdateSelection: onUpdateSelection,
              onDone: () {
                onUpdateSelectionmode(enable: !selectionMode);
              },
            );
          },
        );
      },
    );
  }
}

class SelectionContol0 extends StatefulWidget {
  const SelectionContol0({
    required this.tabIdentifier,
    required this.selector,
    required this.builder,
    required this.itemBuilder,
    required this.labelBuilder,
    required this.selectionActionsBuilder,
    required this.onSelectionChanged,
    required this.onUpdateSelection,
    required this.onDone,
    super.key,
  });
  final TabIdentifier tabIdentifier;
  final CLSelector selector;
  final Widget Function(BuildContext, CLEntity) itemBuilder;
  final Widget? Function(
    BuildContext context,
    List<GalleryGroupCLEntity<CLEntity>> galleryMap,
    GalleryGroupCLEntity<CLEntity> gallery,
  ) labelBuilder;
  final Widget Function({
    required List<CLEntity> items,
    required Widget Function(BuildContext, CLEntity) itemBuilder,
    required Widget? Function(
      BuildContext context,
      List<GalleryGroupCLEntity<CLEntity>> galleryMap,
      GalleryGroupCLEntity<CLEntity> gallery,
    ) labelBuilder,
    required List<Widget> Function(
      BuildContext context,
      List<GalleryGroupCLEntity<CLEntity>> galleryMap,
    ) bannersBuilder,
  }) builder;

  final List<CLMenuItem> Function(BuildContext, List<CLEntity>)?
      selectionActionsBuilder;
  final void Function(List<CLEntity>)? onSelectionChanged;
  final void Function(List<CLEntity>? candidates, {bool? deselect})
      onUpdateSelection;
  final void Function() onDone;

  @override
  State<StatefulWidget> createState() => _SelectionContol0State();
}

class _SelectionContol0State extends State<SelectionContol0> {
  final GlobalKey parentKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final incoming = widget.selector.entities;

    return Stack(
      key: parentKey,
      children: [
        widget.builder(
          items: incoming,
          itemBuilder: (context, item) {
            final itemWidget = widget.itemBuilder(
              context,
              item,
            );

            return SelectableItem(
              isSelected: widget.selector.isSelected([item]) !=
                  SelectionStatus.selectedNone,
              onTap: () {
                widget.onUpdateSelection([item]);
              },
              child: itemWidget,
            );
          },
          labelBuilder: (context, galleryMap, gallery) {
            final labelWidget =
                widget.labelBuilder(context, galleryMap, gallery);
            if (labelWidget == null) return const SizedBox.shrink();
            final candidates =
                galleryMap.getEntitiesByGroup(gallery.groupIdentifier).toList();
            return SelectableLabel(
              selectionStatus: widget.selector.isSelected(
                candidates,
              ),
              onSelect: () {
                widget.onUpdateSelection(
                  candidates,
                );
              },
              child: labelWidget,
            );
          },
          bannersBuilder: (context, galleryMap) {
            return [
              SelectionBanner(
                onClose: widget.onDone,
                selector: widget.selector,
                galleryMap: galleryMap,
                onUpdateSelection: widget.onUpdateSelection,
              ),
            ];
          },
        ),
        if (widget.selector.items.isNotEmpty &&
            widget.selectionActionsBuilder != null)
          ActionsDraggableMenu<CLEntity>(
            items: widget.selector.items.toList(),
            tagPrefix: 'Selection',
            onDone: widget.onDone,
            selectionActionsBuilder: widget.selectionActionsBuilder,
            parentKey: parentKey,
          ),
      ],
    );
  }
}

class SelectionBanner extends StatelessWidget {
  const SelectionBanner({
    required this.onUpdateSelection,
    required this.selector,
    required this.onClose,
    super.key,
    this.galleryMap = const [],
  });
  final CLSelector selector;
  final List<GalleryGroupCLEntity> galleryMap;
  final void Function(List<CLEntity>? candidates, {bool? deselect})
      onUpdateSelection;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
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
        onUpdateSelection(currentItems);
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
                          onUpdateSelection(selectedInVisible, deselect: true);
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
                        ..onTap = () => onUpdateSelection(null),
                    ),
                  ],
                ),
              ),
          ] else if (onClose != null)
            ShadButton.secondary(
              onPressed: onClose,
              child: const CLText.small(
                'Done',
              ),
            ),
        ],
      ),
    );
  }
}

class SelectionControlIcon extends ConsumerWidget {
  const SelectionControlIcon({required this.viewIdentifier, super.key});

  final ViewIdentifier viewIdentifier;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return GetSelectionMode(
      viewIdentifier: viewIdentifier,
      builder: ({
        required onUpdateSelectionmode,
        required tabIdentifier,
        required selectionMode,
      }) {
        if (tabIdentifier.tabId != 'Media') {
          return const SizedBox.shrink();
        } else {
          return ShadButton.ghost(
            padding: const EdgeInsets.only(right: 8),
            onPressed: () {
              onUpdateSelectionmode(enable: !selectionMode);
            },
            child: const Icon(LucideIcons.listChecks),
          );
        }
      },
    );
  }
}
