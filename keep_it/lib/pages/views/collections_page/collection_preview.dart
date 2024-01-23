import 'package:flutter/material.dart';

class CollectionPreview extends StatelessWidget {
  const CollectionPreview({
    required this.backgroundColor,
    super.key,
    this.child,
  });

  final Widget? child;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: SizedBox.square(
        dimension: 128,
        child: Padding(
          padding: const EdgeInsets.all(2),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: backgroundColor,
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
