// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PaginationInfo {
  final List items;
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

extension ExtONDouble on double {
  double nearest(double value) {
    if (value == 0.0) {
      // Avoid division by zero
      return value;
    }
    return ((this / value).floor() * value);
  }
}

class PaginatedList {
  late final List<List<List>> pages;
  late int itemsInRow;
  late int itemsInColumn;
  final PaginationInfo paginationInfo;
  calculateItemsPerPage(Size itemSize, BoxConstraints constraints) {}

  PaginatedList(this.paginationInfo) {
    final pageSize = paginationInfo.pageSize;
    final itemSize = paginationInfo.itemSize;
    final items = paginationInfo.items;
    itemsInRow =
        ((pageSize.width.nearest(itemSize.width)) / itemSize.width).floor();
    itemsInColumn =
        ((pageSize.height.nearest(itemSize.height)) / itemSize.height).floor();
    itemsInRow = max(1, itemsInRow);
    itemsInColumn = max(1, itemsInColumn);
    pages = [];
    for (var p in paginate(items, itemsInRow * itemsInColumn)) {
      pages.add(paginate(p, itemsInRow));
    }
  }
  List<List<T>> paginate<T>(List<T> list, int pageLength) {
    List<List<T>> pages = [];
    for (int i = 0; i < list.length; i += pageLength) {
      int end = (i + pageLength < list.length) ? i + pageLength : list.length;
      pages.add(list.sublist(i, end));
    }
    return pages;
  }

  int get pageMax => pages.length;

  List<List> page(int pageNum) {
    if (pageNum >= pageMax) {
      return pages[pageMax - 1];
    }
    return pages[pageNum];
  }

  dynamic getItem(int pageNum, int r, int c) {
    if (pages[pageNum].length <= r) return null;
    if (pages[pageNum][r].length <= c) return null;
    return pages[pageNum][r][c];
  }
}

final paginatedListProvider =
    StateProvider.family<PaginatedList, PaginationInfo>((ref, paginationInfo) {
  return PaginatedList(paginationInfo);
});
