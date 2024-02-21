extension ExtDimension<T> on List<T> {
  List<List<T>> convertTo2D(int innerDimension) {
    final pages = <List<T>>[];
    for (var i = 0; i < length; i += innerDimension) {
      final end = (i + innerDimension < length) ? i + innerDimension : length;
      pages.add(sublist(i, end));
    }
    return pages;
  }

  List<T> firstNItems(int n) {
    if (length <= n) {
      return this; // Return the list as it is
    } else {
      return sublist(0, n); // Return the first N items
    }
  }

  List<T> removeFirstItem() {
    if (isNotEmpty) {
      return List<T>.from(this)..removeAt(0);
    } else {
      return this;
    }
  }
}

extension ExtExclude<T> on List<T> {
  Iterable<T> excludeByLabel(
    List<T> another,
    String Function(T obj) labelBuilder,
  ) {
    return where((e) {
      return !another.map(labelBuilder).contains(labelBuilder(e));
    });
  }

  Iterable<T> excludeLabel(
    String label,
    String Function(T obj) labelBuilder,
  ) {
    return where(
      (e) => labelBuilder(e) != label,
    );
  }

  T? getByLabel(
    String label,
    String Function(T obj) labelBuilder,
  ) {
    return where(
      (e) => labelBuilder(e) == label,
    ).firstOrNull;
  }
}
