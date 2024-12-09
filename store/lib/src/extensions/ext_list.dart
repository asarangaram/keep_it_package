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
