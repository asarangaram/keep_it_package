import 'dart:math';

import 'package:flutter/material.dart';

class PlaceHolderGrid extends StatelessWidget {
  const PlaceHolderGrid(
    this.count, {
    required this.columns,
    super.key,
  });

  final int count;
  final int columns;

  static Widget? _placeHolderCache;
  static final _placeHolderGrid = <String, Widget>{};
  static const crossAxisSpacing = 2.0; // as per your code
  static const mainAxisSpacing = 2.0; // as per your code

  @override
  Widget build(BuildContext context) {
    const Color faintColor = Colors.grey;

    final int limitCount = min(count, 8);

    final key = '$limitCount:$columns';
    if (!_placeHolderGrid.containsKey(key)) {
      _placeHolderGrid[key] = GridView.builder(
        padding: const EdgeInsets.only(top: 2),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return PlaceHolderGrid._placeHolderCache ??=
              Container(color: faintColor);
        },
        itemCount: limitCount,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: columns,
          crossAxisSpacing: crossAxisSpacing,
          mainAxisSpacing: mainAxisSpacing,
        ),
      );
    }
    return _placeHolderGrid[key]!;
  }
}
