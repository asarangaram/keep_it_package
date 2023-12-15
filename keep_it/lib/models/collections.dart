import 'package:flutter/material.dart';

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

class PaginatedCollection {
  final List<Collection> items;
  final Size pageSize;
  final Size itemSize;
  late final List<List<List<Collection>>> pages;
  late int itemsInRow;
  late int itemsInColumn;

  calculateItemsPerPage(Size itemSize, BoxConstraints constraints) {}

  PaginatedCollection(
      {required this.items, required this.pageSize, required this.itemSize}) {
    itemsInRow = ((pageSize.width - 32) / itemSize.width).floor();
    itemsInColumn = ((pageSize.height - 32) / itemSize.height).floor();
    pages = [];
    for (var p in paginate(items, itemsInRow * itemsInColumn)) {
      pages.add(paginate(p, itemsInRow));
    }
  }

  int get pageMax => pages.length;

  List<List<Collection>> page(int pageNum) {
    if (pageNum >= pageMax) {
      return pages[pageMax - 1];
    }
    return pages[pageNum];
  }

  Collection? getItem(int pageNum, int r, int c) {
    if (pages[pageNum].length <= r) return null;
    if (pages[pageNum][r].length <= c) return null;
    return pages[pageNum][r][c];
  }
}
