import 'package:flutter/material.dart';

import '../theme/state/cl_theme.dart';
import 'cl_button.dart';

class CircledIcon extends StatelessWidget {
  const CircledIcon(this.iconData, {super.key, this.onTap});
  final IconData iconData;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: CLTheme.of(context)
              .colors
              .iconBackgroundTransparent, // Color for the circular container
        ),
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: CLButtonIcon.verySmall(
            iconData,
            color: CLTheme.of(context).colors.iconColorTransparent,
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}
