import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cl_basic_types/cl_basic_types.dart';
import '../models/selector.dart';

import '../providers/select_mode.dart';
import '../providers/selector.dart';

class SelectableLabel extends ConsumerWidget {
  const SelectableLabel({
    super.key,
    required this.galleryMap,
    required this.gallery,
  });

  final List<ViewerEntityGroup<ViewerEntity>> galleryMap;
  final ViewerEntityGroup<ViewerEntity> gallery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (gallery.label == null) return const SizedBox.shrink();
    final labelWidget = CLText.large(
      gallery.label!,
      textAlign: TextAlign.start,
    );

    final selectionMode = ref.watch(selectModeProvider);
    if (!selectionMode) {
      return labelWidget;
    }
    final candidates = ViewerEntities(
        galleryMap.getEntitiesByGroup(gallery.groupIdentifier).toList());
    final selectionStatus =
        ref.watch(selectorProvider.select((e) => e.isSelected(candidates)));
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: labelWidget,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            child: GestureDetector(
              onTap: () {
                ref.read(selectorProvider.notifier).updateSelection(
                      candidates,
                    );
              },
              child: CLIcon.small(
                switch (selectionStatus) {
                  SelectionStatus.selectedNone => clIcons.itemNotSelected,
                  SelectionStatus.selectedPartial =>
                    clIcons.itemPartiallySelected,
                  SelectionStatus.selectedAll => clIcons.itemSelected,
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
