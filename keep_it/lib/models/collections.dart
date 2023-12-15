import 'collection.dart';

List<List<T>> paginate<T>(List<T> list, int pageLength) {
  List<List<T>> pages = [];
  for (int i = 0; i < list.length; i += pageLength) {
    int end = (i + pageLength < list.length) ? i + pageLength : list.length;
    pages.add(list.sublist(i, end));
  }
  return pages;
}

class Collections {
  final List<Collection> collections;

  Collections(this.collections);

  bool get isEmpty => collections.isEmpty;
  bool get isNotEmpty => collections.isNotEmpty;
}

class PaginateddCollection {
  final List<Collection> items;
  late final List<List<Collection>> pages;

  final int itemsPerPage;

  PaginateddCollection({required this.items, required this.itemsPerPage}) {
    pages = paginate(items, itemsPerPage);
  }

  int get pageMax => pages.length;

  List<Collection> page(int pageNum) {
    if (pageNum >= pageMax) {
      return pages[pageMax - 1];
    }
    return pages[pageNum];
  }
}
