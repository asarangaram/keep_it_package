import 'package:flutter/material.dart';

import '../../../basics/cl_icon.dart';
import '../../../theme/models/cl_icons.dart';
import '../../../theme/state/cl_theme.dart';

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
        child,
        Positioned.fill(
          child: GestureDetector(
            onTap: onTap,
            child: SizedBox.expand(
              child: Container(
                decoration: decoration,
                child: isSelected
                    ? Center(child: OverlayIcon(clIcons.itemSelected))
                    : null,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class OverlayIcon extends StatelessWidget {
  const OverlayIcon(
    this.iconData, {
    super.key,
  });
  final IconData iconData;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 0.3,
      heightFactor: 0.3,
      child: FittedBox(
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Theme.of(
              context,
            ).colorScheme.onSurface.withAlpha(
                  192,
                ), // Color for the circular container
          ),
          child: CLIcon.veryLarge(
            iconData,
            color: CLTheme.of(context).colors.iconColorTransparent,
          ),
        ),
      ),
    );
  }
}
