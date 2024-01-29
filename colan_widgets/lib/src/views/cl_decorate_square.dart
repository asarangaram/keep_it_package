import 'package:flutter/material.dart';

class CLDecorateSquare extends StatelessWidget {
  const CLDecorateSquare({
    super.key,
    this.child,
    this.hasBorder = false,
    this.borderRadius,
  });

  final Widget? child;
  final bool hasBorder;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: ClipRRect(
          borderRadius:
              borderRadius ?? const BorderRadius.all(Radius.circular(12)),
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: hasBorder ? Border.all() : null,
              borderRadius:
                  borderRadius ?? const BorderRadius.all(Radius.circular(12)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
