import 'package:flutter/material.dart';

@immutable
class CLDimension {
  const CLDimension({
    required this.itemsInRow,
    required this.itemsInColumn,
  });
  final int itemsInRow;
  final int itemsInColumn;

  @override
  bool operator ==(covariant CLDimension other) {
    if (identical(this, other)) return true;

    return other.itemsInRow == itemsInRow &&
        other.itemsInColumn == itemsInColumn;
  }

  @override
  int get hashCode => itemsInRow.hashCode ^ itemsInColumn.hashCode;

  @override
  String toString() => 'Dimension(width: $itemsInRow, height: $itemsInColumn)';

  int get totalCount => itemsInRow * itemsInColumn;
}
