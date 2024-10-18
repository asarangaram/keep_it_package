// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:store/store.dart';

@immutable
class SegregatedItems {
  const SegregatedItems({
    required this.existingItemsNoChange,
    required this.existingItemsCollectionChanged,
    required this.newItems,
  });
  final List<CLMedia> existingItemsNoChange;
  final List<CLMedia> existingItemsCollectionChanged;
  final List<CLMediaBase> newItems;

  @override
  String toString() =>
      // ignore: lines_longer_than_80_chars
      'SegregatedItems(existingItemsNoChange: $existingItemsNoChange, existingItemsCollectionChanged: $existingItemsCollectionChanged, newItems: $newItems)';

  @override
  bool operator ==(covariant SegregatedItems other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.existingItemsNoChange, existingItemsNoChange) &&
        listEquals(
          other.existingItemsCollectionChanged,
          existingItemsCollectionChanged,
        ) &&
        listEquals(other.newItems, newItems);
  }

  @override
  int get hashCode =>
      existingItemsNoChange.hashCode ^
      existingItemsCollectionChanged.hashCode ^
      newItems.hashCode;

  SegregatedItems copyWith({
    List<CLMedia>? existingItemsNoChange,
    List<CLMedia>? existingItemsCollectionChanged,
    List<CLMediaBase>? newItems,
  }) {
    return SegregatedItems(
      existingItemsNoChange:
          existingItemsNoChange ?? this.existingItemsNoChange,
      existingItemsCollectionChanged:
          existingItemsCollectionChanged ?? this.existingItemsCollectionChanged,
      newItems: newItems ?? this.newItems,
    );
  }
}
