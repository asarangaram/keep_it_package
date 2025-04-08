import 'package:store/src/extensions/ext_datetime.dart';
import 'package:store/src/extensions/ext_list.dart';

import 'gallery_group.dart';

abstract class ViewerEntityMixin {
  int? get id;
  bool get isCollection;
  DateTime get sortDate;
  int? get parentId;
}

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
