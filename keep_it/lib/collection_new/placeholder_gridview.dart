import 'dart:math';

import 'package:flutter/material.dart';

class PlaceHolderGridView extends StatelessWidget {
  const PlaceHolderGridView(
    this.count,
    this.columns, {
    super.key,
  });

  final int count;
  final int columns;

  static Widget? _placeHolderCache;
  static final _gridViewCache = <String, GridView>{};
  static const crossAxisSpacing = 2.0; // as per your code
  static const mainAxisSpacing = 2.0; // as per your code

  @override
  Widget build(BuildContext context) {
    const Color faintColor = Colors.grey;

    final int limitCount = min(count, 8);

    final key = '$limitCount:$columns';
    if (!_gridViewCache.containsKey(key)) {
      _gridViewCache[key] = GridView.builder(
        padding: const EdgeInsets.only(top: 2),
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          return PlaceHolderGridView._placeHolderCache ??=
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
    return _gridViewCache[key]!;
  }
}
