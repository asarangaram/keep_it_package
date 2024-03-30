import 'package:flutter/material.dart';

import '../../../basics/cl_icon.dart';

class SelectableLabel extends StatelessWidget {
  const SelectableLabel({
    required this.child,
    required this.selectionMap,
    super.key,
    this.onSelect,
  });
  final Widget child;
  final List<bool> selectionMap;
  final void Function({required bool select})? onSelect;

  @override
  Widget build(BuildContext context) {
    final noneSelected = selectionMap.every((e) => e == false);
    final partialSelected = selectionMap.any((e) => e == false);
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
              onTap: () => onSelect?.call(select: noneSelected),
              child: CLIcon.small(
                noneSelected
                    ? Icons.check_box_outline_blank
                    : partialSelected
                        ? Icons.indeterminate_check_box_outlined
                        : Icons.check_box,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
