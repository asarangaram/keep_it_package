extension ExtDimension on List {
  List<List> convertTo2D(int innerDimension) {
    List<List> pages = [];
    for (int i = 0; i < length; i += innerDimension) {
      int end = (i + innerDimension < length) ? i + innerDimension : length;
      pages.add(sublist(i, end));
    }
    return pages;
  }
}
