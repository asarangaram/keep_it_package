import 'dart:math';

import 'package:collection/collection.dart';

extension IndexExtonList<T> on List<T> {
  List<T> replaceNthEntry(int index, T newValue) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length);
    }

    return [
      ...sublist(0, index), // Elements before the index
      newValue, // New value at the index
      ...sublist(index + 1), // Elements after the index
    ];
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
