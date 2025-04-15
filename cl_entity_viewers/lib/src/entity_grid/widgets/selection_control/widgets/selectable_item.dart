import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/material.dart';

class SelectableItem extends StatelessWidget {
  const SelectableItem({
    required this.child,
    required this.onTap,
    required this.isSelected,
    super.key,
  });
  final Widget child;
  final void Function() onTap;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
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
        Positioned.fill(child: child),
        Positioned.fill(
          child: GestureDetector(
            onTap: onTap,
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
