import 'package:flutter/material.dart';

class CLAspectRationDecorated extends StatelessWidget {
  const CLAspectRationDecorated({
    super.key,
    this.child,
    this.hasBorder = false,
    this.borderRadius = BorderRadius.zero,
    this.borderColor,
    this.padding = EdgeInsets.zero,
    this.aspectRatio = 1.0,
  });

  final Widget? child;
  final bool hasBorder;
  final BorderRadiusGeometry borderRadius;
  final EdgeInsets padding;
  final double aspectRatio;
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: aspectRatio,
      child: Padding(
        padding: padding,
        child: ClipRRect(
          borderRadius: borderRadius,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: hasBorder
                  ? Border.all(color: borderColor ?? const Color(0xFF000000))
                  : null,
              borderRadius: borderRadius,
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
