// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:math';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class PaginationInfo {
  final List<dynamic> items;
  final Size pageSize;
  final Size itemSize;

  const PaginationInfo({
    required this.items,
    required this.pageSize,
    required this.itemSize,
  });

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

class PaginatedList {
  late final List<List<List<dynamic>>> pages;
  late int itemsInRow;
  late int itemsInColumn;
  final PaginationInfo paginationInfo;

  PaginatedList(this.paginationInfo) {
    final pageSize = paginationInfo.pageSize;
    final itemSize = paginationInfo.itemSize;
    final items = paginationInfo.items;
    final s = pageMatrix(pageSize: pageSize, itemSize: itemSize);
    pages = [];
    for (final p in items.convertTo2D(s.width * s.height)) {
      pages.add(p.convertTo2D(itemsInRow));
    }
  }

  int get pageMax => pages.length;

  List<List<dynamic>> page(int pageNum) {
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

  CLDimension pageMatrix({required Size pageSize, required Size itemSize}) {
    try {
      if (pageSize.width == double.infinity) {
        throw Exception("Width is unbounded, can't handle");
      }
      if (pageSize.height == double.infinity) {
        throw Exception("Width is unbounded, can't handle");
      }
      itemsInRow =
          ((pageSize.width.nearest(itemSize.width)) / itemSize.width).floor();
      itemsInColumn =
          ((pageSize.height.nearest(itemSize.height)) / itemSize.height)
              .floor();
    } catch (e) {
      rethrow;
    }
    itemsInRow = max(1, itemsInRow);
    itemsInColumn = max(1, itemsInColumn);
    return CLDimension(width: itemsInRow, height: itemsInColumn);
  }
}

final paginatedListProvider =
    StateProvider.family<PaginatedList, PaginationInfo>((ref, paginationInfo) {
  return PaginatedList(paginationInfo);
});
