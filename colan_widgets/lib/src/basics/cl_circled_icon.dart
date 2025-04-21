import 'package:flutter/material.dart';

import '../theme/state/cl_theme.dart';
import 'svg_icon.dart';

class CircledIcon extends StatelessWidget {
  const CircledIcon(
    this.iconData, {
    super.key,
    this.onTap,
    this.shape = BoxShape.circle,
    this.color,
  });
  final IconData iconData;
  final VoidCallback? onTap;
  final BoxShape shape;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: GestureDetector(
        onTap: onTap,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: shape,
            color: CLTheme.of(context)
                .colors
                .iconBackgroundTransparent, // Color for the circular container
          ),
          child: Padding(
            padding: const EdgeInsets.all(6),
            child: Icon(
              iconData,
              color: color ?? CLTheme.of(context).colors.iconColorTransparent,
            ),
          ),
        ),
      ),
    );
  }
}

class CircledSvgIcon extends StatelessWidget {
  const CircledSvgIcon(
    this.iconData, {
    super.key,
    this.onTap,
    this.shape = BoxShape.circle,
    this.color,
  });
  final SvgIcons iconData;
  final VoidCallback? onTap;
  final BoxShape shape;
  final Color? color;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          shape: shape,
          color: CLTheme.of(context)
              .colors
              .iconBackgroundTransparent, // Color for the circular container
        ),
        child: Padding(
          padding: const EdgeInsets.all(6),
          child: GestureDetector(
            onTap: onTap,
            child: SvgIcon(
              iconData,
              color: color,
            ),
          ),
        ),
      ),
    );
  }
}
