import 'dart:math';

import 'package:collection/collection.dart';

extension Reshape<T> on List<T> {
  List<List<T>> convertTo2D(int innerDimension) {
    final pages = <List<T>>[];
    for (var i = 0; i < length; i += innerDimension) {
      final end = (i + innerDimension < length) ? i + innerDimension : length;
      pages.add(sublist(i, end));
    }
    return pages;
  }
}

extension IndexExtonNullableList<T> on List<T?> {
  List<T> get nonNullableList {
    return where((e) => e != null).map((e) => e!).toList();
  }
}

extension IndexExtonNullableIterable<T> on Iterable<T?> {
  List<T> get nonNullableList {
    return where((e) => e != null).map((e) => e!).toList();
  }

  Set<T> get nonNullableSet {
    return where((e) => e != null).map((e) => e!).toSet();
  }
}

extension RandomExt<T> on List<T> {
  List<T> pickRandomItems(int count) {
    final copyList = List<T>.from(this); // Create a copy of the original list
    if (copyList.length <= count) {
      return copyList; // Return the entire list if it's shorter than 'count'
    }

    copyList.shuffle(Random()); // Shuffle the copy list
    return copyList.take(count).toList();
  }
}

extension CompareExtOnSet<T> on Set<T> {
  bool isSame(Set<T> other) {
    // If the lengths are not the same, the lists can't be equal
    if (length != other.length) {
      return false;
    }

    // Sort both lists
    final sortedList1 = List<T>.from(this)..sort();
    final sortedList2 = List<T>.from(other)..sort();

    // Compare the sorted lists
    return ListEquality<T>().equals(sortedList1, sortedList2);
  }

  bool isDifferent(Set<T> other) => !isSame(other);
}

extension CompareExtOnList<T> on List<T> {
  bool isSame(List<T> other) {
    // If the lengths are not the same, the lists can't be equal
    if (length != other.length) {
      return false;
    }

    // Sort both lists
    final sortedList1 = List<T>.from(this)..sort();
    final sortedList2 = List<T>.from(other)..sort();

    // Compare the sorted lists
    return ListEquality<T>().equals(sortedList1, sortedList2);
  }

  bool isDifferent(List<T> other) => isSame(other);
}
