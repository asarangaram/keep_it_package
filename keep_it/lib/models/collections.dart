// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

class PaginationInfo {
  final List<Collection> items;
  final Size pageSize;
  final Size itemSize;

  PaginationInfo(
      {required this.items, required this.pageSize, required this.itemSize});

  @override
  bool operator ==(covariant PaginationInfo other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.items, items) &&
        other.pageSize == pageSize &&
        other.itemSize == itemSize;
  }

  @override
  int get hashCode => items.hashCode ^ pageSize.hashCode ^ itemSize.hashCode;
}

class PaginatedCollection {
  late final List<List<List<Collection>>> pages;
  late int itemsInRow;
  late int itemsInColumn;
  final PaginationInfo paginationInfo;
  calculateItemsPerPage(Size itemSize, BoxConstraints constraints) {}

  PaginatedCollection(this.paginationInfo) {
    final pageSize = paginationInfo.pageSize;
    final itemSize = paginationInfo.itemSize;
    final items = paginationInfo.items;
    itemsInRow =
        ((((pageSize.width / 200).floor() * 200) - 32) / itemSize.width)
            .floor();
    itemsInColumn =
        ((((pageSize.height / 200).floor() * 200) - 32) / itemSize.height)
            .floor();
    itemsInRow = max(1, itemsInRow);
    itemsInColumn = max(1, itemsInColumn);
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

final paginatedCollectionProvider =
    StateProvider.family<PaginatedCollection, PaginationInfo>(
        (ref, paginationInfo) {
  return PaginatedCollection(paginationInfo);
});
