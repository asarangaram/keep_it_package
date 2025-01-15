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
