import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'view_modifier.dart';

@immutable
class PopOverMenuItems {
  const PopOverMenuItems({
    required this.items,
    this.currIndex = 0,
  });
  final List<ViewModifier> items;
  final int currIndex;

  ViewModifier? get currItem =>
      (currIndex >= 0 && currIndex < items.length) ? items[currIndex] : null;

  PopOverMenuItems copyWith({
    ValueGetter<int>? currIndex,
  }) {
    return PopOverMenuItems(
      items: items,
      currIndex: currIndex != null ? currIndex() : this.currIndex,
    );
  }

  @override
  String toString() => 'PopOverMenuItems(items: $items, currIndex: $currIndex)';

  @override
  bool operator ==(covariant PopOverMenuItems other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.items, items) && other.currIndex == currIndex;
  }

  @override
  int get hashCode => items.hashCode ^ currIndex.hashCode;
}
