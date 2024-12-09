import 'package:flutter/material.dart';

import '../theme/state/cl_theme.dart';
import 'cl_icon.dart';

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
