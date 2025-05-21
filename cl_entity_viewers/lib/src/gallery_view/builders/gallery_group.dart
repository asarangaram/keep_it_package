import 'package:flutter/foundation.dart';
import '../../common/models/viewer_entity_mixin.dart';
import '../../common/extensions/ext_datetime.dart';
import '../../common/extensions/list_ext.dart';

extension EntityGrouper on List<ViewerEntityMixin> {
  Map<String, List<ViewerEntityMixin>> filterByDate() {
    final filterredMedia = <String, List<ViewerEntityMixin>>{};
    final noDate = <ViewerEntityMixin>[];
    for (final entry in this) {
      final String formattedDate;

      if (entry.createDate != null) {
        formattedDate = entry.createDate!.toDisplayFormat(dataOnly: true);
      } else {
        formattedDate = '${entry.updatedDate.toDisplayFormat(dataOnly: true)} '
            '(upload date)';
      }

      if (!filterredMedia.containsKey(formattedDate)) {
        filterredMedia[formattedDate] = [];
      }
      filterredMedia[formattedDate]!.add(entry);
    }
    if (noDate.isNotEmpty) {
      filterredMedia['No Date'] = noDate;
    }

    return filterredMedia;
  }

  List<ViewerEntityGroup<ViewerEntityMixin>> groupByTime(int columns) {
    final galleryGroups = <ViewerEntityGroup<ViewerEntityMixin>>[];

    for (final entry in filterByDate().entries) {
      if (entry.value.length > columns) {
        final groups = entry.value.convertTo2D(columns);

        for (final (index, group) in groups.indexed) {
          galleryGroups.add(
            ViewerEntityGroup(
              group,
              label: (index == 0) ? entry.key : null,
              groupIdentifier: entry.key,
              chunkIdentifier: '${entry.key} $index',
            ),
          );
        }
      } else {
        galleryGroups.add(
          ViewerEntityGroup(
            entry.value,
            label: entry.key,
            groupIdentifier: entry.key,
            chunkIdentifier: entry.key,
          ),
        );
      }
    }
    return galleryGroups;
  }

  List<ViewerEntityGroup<ViewerEntityMixin>> group(int columns) {
    final galleryGroups = <ViewerEntityGroup<ViewerEntityMixin>>[];

    for (final rows in convertTo2D(columns)) {
      galleryGroups.add(
        ViewerEntityGroup(
          rows,
          label: null,
          groupIdentifier: 'StoreEntity',
          chunkIdentifier: 'StoreEntity',
        ),
      );
    }
    return galleryGroups;
  }
}

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
