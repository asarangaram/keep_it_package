import 'package:content_store/extensions/ext_datetime.dart';
import 'package:content_store/extensions/list_ext.dart';
import 'package:meta/meta.dart';

import 'package:store/store.dart';

extension EntityGrouper on List<ViewerEntityMixin> {
  Map<String, List<ViewerEntityMixin>> filterByDate() {
    final filterredMedia = <String, List<ViewerEntityMixin>>{};
    final noDate = <ViewerEntityMixin>[];
    for (final entry in this) {
      final String formattedDate;

      formattedDate = '${entry.sortDate.toDisplayFormat(dataOnly: true)} '
          '(upload date)';

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

  List<GalleryGroupStoreEntity<ViewerEntityMixin>> groupByTime(int columns) {
    final galleryGroups = <GalleryGroupStoreEntity<ViewerEntityMixin>>[];

    for (final entry in filterByDate().entries) {
      if (entry.value.length > columns) {
        final groups = entry.value.convertTo2D(columns);

        for (final (index, group) in groups.indexed) {
          galleryGroups.add(
            GalleryGroupStoreEntity(
              group,
              label: (index == 0) ? entry.key : null,
              groupIdentifier: entry.key,
              chunkIdentifier: '${entry.key} $index',
            ),
          );
        }
      } else {
        galleryGroups.add(
          GalleryGroupStoreEntity(
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

  List<GalleryGroupStoreEntity<ViewerEntityMixin>> group(int columns) {
    final galleryGroups = <GalleryGroupStoreEntity<ViewerEntityMixin>>[];

    for (final rows in convertTo2D(columns)) {
      galleryGroups.add(
        GalleryGroupStoreEntity(
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

@immutable
class GalleryGroupStoreEntity<T extends ViewerEntityMixin> {
  const GalleryGroupStoreEntity(
    this.items, {
    required this.chunkIdentifier,
    required this.groupIdentifier,
    required this.label,
  });
  final String chunkIdentifier;
  final String groupIdentifier;
  final String? label;
  final List<T> items;

  Set<int?> get getEntityIds => items.map((e) => e.id).toSet();
}

extension GalleryGroupStoreEntityListQuery<T extends ViewerEntityMixin>
    on List<GalleryGroupStoreEntity<T>> {
  Set<int?> get getEntityIds => expand((item) => item.getEntityIds).toSet();
  Set<T> get getEntities => expand((item) => item.items).toSet();

  Set<int?> getEntityIdsByGroup(String groupIdentifier) =>
      where((e) => e.groupIdentifier == groupIdentifier)
          .expand((item) => item.getEntityIds)
          .toSet();

  Set<T> getEntitiesByGroup(String groupIdentifier) =>
      where((e) => e.groupIdentifier == groupIdentifier)
          .expand((item) => item.items)
          .toSet();
}
