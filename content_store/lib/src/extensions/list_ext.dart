import 'package:collection/collection.dart';

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