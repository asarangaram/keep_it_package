// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/foundation.dart';

@immutable
class GalleryGroup<T> {
  const GalleryGroup(
    this.items, {
    required this.chunkIdentifier,
    required this.groupIdentifier,
    required this.label,
  });
  final String chunkIdentifier;
  final String groupIdentifier;
  final String? label;
  final List<T> items;
}

class GalleryGroupMutable<T> {
  const GalleryGroupMutable(
    this.items, {
    required this.chunkIdentifier,
    required this.groupIdentifier,
  });
  final String chunkIdentifier;
  final String groupIdentifier;
  final List<T> items;
}

extension ExtListGalleryGroupMutable<T> on List<GalleryGroupMutable<T>> {
  int get totalCount => fold<int>(
        0,
        (previousValue, element) => previousValue + element.items.length,
      );
}

extension IterableExtensions<E> on Iterable<E> {
  E? firstWhereOrNull(bool Function(E element) test) {
    for (final element in this) {
      if (test(element)) {
        return element;
      }
    }
    return null;
  }
}

extension IterableIndexedExtensions<E> on Iterable<E> {
  void forEachIndexed(void Function(int index, E element) action) {
    var index = 0;
    for (final element in this) {
      action(index, element);
      index++;
    }
  }
}

extension ExtListGalleryGroupMutableBool<bool>
    on List<GalleryGroupMutable<bool>> {
  int get trueCount => fold<int>(
        0,
        (previousValue, element) =>
            previousValue +
            element.items.where((element) => element == true).length,
      );

  List<T> filterItems<T>(List<GalleryGroup<T>> originalList) {
    final items = <T>[];
    for (final group in originalList) {
      final boolGroup = firstWhereOrNull(
        (mutableGroup) => mutableGroup.chunkIdentifier == group.chunkIdentifier,
      );
      boolGroup?.items.forEachIndexed((index, flag) {
        if (flag == true) {
          items.add(group.items[index]);
        }
      });
    }
    return items;
  }
}
