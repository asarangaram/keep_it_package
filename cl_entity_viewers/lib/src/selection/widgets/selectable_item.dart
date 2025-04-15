import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entity/models/viewer_entity_mixin.dart';
import '../models/selector.dart';
import '../../gallery_grid_view/models/tab_identifier.dart';

import '../providers/select_mode.dart';
import '../providers/selector.dart';

class SelectableItem extends ConsumerWidget {
  const SelectableItem({
    required this.tabIdentifier,
    required this.item,
    required this.itemBuilder,
    super.key,
  });
  final TabIdentifier tabIdentifier;
  final ViewerEntityMixin item;
  final Widget Function(BuildContext, ViewerEntityMixin) itemBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectionMode = ref.watch(selectModeProvider(tabIdentifier));

    final itemWidget = itemBuilder(
      context,
      item,
    );
    if (!selectionMode) {
      return itemWidget;
    }

    final isSelected =
        ref.watch(selectorProvider.select((e) => e.isSelected([item]))) !=
            SelectionStatus.selectedNone;

    final decoration = isSelected
        ? BoxDecoration(
            border:
                Border.all(color: const Color.fromARGB(255, 0x08, 0xFF, 0x08)),
          )
        : BoxDecoration(
            color: Theme.of(context).colorScheme.surface.withAlpha(128),
          );
    return Stack(
      children: [
        Positioned.fill(child: itemWidget),
        Positioned.fill(
          child: GestureDetector(
            onTap: () =>
                ref.read(selectorProvider.notifier).updateSelection([item]),
            child: SizedBox.expand(
              child: Container(
                decoration: decoration,
                child: isSelected
                    ? Center(child: OverlayIcon(clIcons.itemSelected2))
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
