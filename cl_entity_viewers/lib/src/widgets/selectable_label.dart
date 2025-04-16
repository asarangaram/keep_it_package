import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/viewer_entity_mixin.dart';
import '../models/tab_identifier.dart';
import '../models/selector.dart';

import '../providers/select_mode.dart';
import '../providers/selector.dart';

class SelectableLabel extends ConsumerWidget {
  const SelectableLabel({
    required this.viewIdentifier,
    super.key,
    required this.galleryMap,
    required this.gallery,
  });
  final ViewIdentifier viewIdentifier;
  final List<ViewerEntityGroup<ViewerEntityMixin>> galleryMap;
  final ViewerEntityGroup<ViewerEntityMixin> gallery;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (gallery.label == null) return const SizedBox.shrink();
    final labelWidget = CLText.large(
      gallery.label!,
      textAlign: TextAlign.start,
    );

    final selectionMode = ref.watch(selectModeProvider(viewIdentifier));
    if (!selectionMode) {
      return labelWidget;
    }
    final candidates =
        galleryMap.getEntitiesByGroup(gallery.groupIdentifier).toList();
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
