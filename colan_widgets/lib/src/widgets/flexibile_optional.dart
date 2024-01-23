import 'package:flutter/material.dart';

class FlexibileOptional extends StatelessWidget {
  const FlexibileOptional({
    required this.child,
    required this.isFlexible,
    super.key,
    this.flex = 1,
    this.fit = FlexFit.loose,
  });
  final Widget child;
  final bool isFlexible;
  final int flex;
  final FlexFit fit;

  @override
  Widget build(BuildContext context) {
    if (!isFlexible) return child;
    return Flexible(
      flex: flex,
      fit: fit,
      child: child,
    );
  }
}
