import 'dart:math';

import 'package:flutter/material.dart';

class CollectionPreview extends StatelessWidget {
  const CollectionPreview({
    required this.random,
    super.key,
    this.child,
  });

  final Random random;
  final Widget? child;

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
              color: Colors.primaries[random.nextInt(Colors.primaries.length)],
              borderRadius: const BorderRadius.all(Radius.circular(12)),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
