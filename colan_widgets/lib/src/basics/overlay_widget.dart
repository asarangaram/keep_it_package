import 'package:flutter/material.dart';

/// open issues
/// the network images are not cached. Should we allow configuring it?
///

class OverlayWidgets extends StatelessWidget {
  factory OverlayWidgets({
    required Widget child,
    required Alignment alignment,
    double? widthFactor = 0.3,
    double? heightFactor = 0.3,
    BoxFit? fit,
    Key? key,
  }) {
    return OverlayWidgets._(
      alignment: alignment,
      widthFactor: widthFactor,
      heightFactor: heightFactor,
      key: key,
      fit: fit,
      child: child,
    );
  }
  factory OverlayWidgets.dimension({
    required Widget child,
    required Alignment alignment,
    double? sizeFactor = 0.3,
    Key? key,
    BoxFit? fit,
  }) {
    return OverlayWidgets._(
      alignment: alignment,
      widthFactor: sizeFactor,
      heightFactor: sizeFactor,
      key: key,
      fit: fit,
      child: child,
    );
  }
  const OverlayWidgets._({
    required this.alignment,
    required this.child,
    super.key,
    this.widthFactor,
    this.heightFactor,
    this.fit,
  });
  final Alignment alignment;
  final Widget child;
  final double? widthFactor;
  final double? heightFactor;
  final BoxFit? fit;
  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: alignment,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        heightFactor: heightFactor,
        child: ClipRect(
          child: FittedBox(
            fit: fit ?? BoxFit.contain,
            child: child,
          ),
        ),
      ),
    );
  }
}
