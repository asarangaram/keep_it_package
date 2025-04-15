import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../entity/models/viewer_entity_mixin.dart';
import '../models/selector.dart';

import '../providers/selector.dart';

class SelectableLabel extends ConsumerWidget {
  const SelectableLabel({
    super.key,
    required this.labelBuilder,
    required this.galleryMap,
    required this.gallery,
  });

  final List<ViewerEntityGroup<ViewerEntityMixin>> galleryMap;
  final ViewerEntityGroup<ViewerEntityMixin> gallery;
  final Widget? Function(
      BuildContext,
      List<ViewerEntityGroup<ViewerEntityMixin>>,
      ViewerEntityGroup<ViewerEntityMixin>) labelBuilder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final labelWidget = labelBuilder(context, galleryMap, gallery);
    if (labelWidget == null) return const SizedBox.shrink();
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
