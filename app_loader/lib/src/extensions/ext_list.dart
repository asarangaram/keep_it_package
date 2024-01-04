extension ExtDimension<T> on List<T> {
  List<List<T>> convertTo2D(int innerDimension) {
    List<List<T>> pages = [];
    for (int i = 0; i < length; i += innerDimension) {
      int end = (i + innerDimension < length) ? i + innerDimension : length;
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
}
