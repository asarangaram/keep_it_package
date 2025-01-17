import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/gallery_view_service/models/selector.dart';

class SelectableLabel extends ConsumerWidget {
  const SelectableLabel({
    required this.child,
    required this.selectionStatus,
    super.key,
    this.onSelect,
  });
  final Widget child;
  final SelectionStatus selectionStatus;
  final void Function()? onSelect;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: child,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
            ),
            child: GestureDetector(
              onTap: () => onSelect?.call(),
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
