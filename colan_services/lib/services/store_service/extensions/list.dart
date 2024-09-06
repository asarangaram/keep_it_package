import 'dart:math';

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
