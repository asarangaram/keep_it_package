import 'ext_datetime.dart';
import 'ext_list.dart';

import 'gallery_group.dart';

abstract class CLEntity {
  bool get isMarkedDeleted;
  bool get isMarkedEditted;
  bool get isMarkedForUpload;
  //int? get getServerUID;
  bool isContentSame(covariant CLEntity other);

  bool get hasServerUID;
  bool isChangedAfter(CLEntity other);
  int? get entityId;

  DateTime? get entityOriginalDate;
  DateTime get entityCreatedDate;
}

extension Filter on List<CLEntity> {
  Map<String, List<CLEntity>> filterByDate() {
    final filterredMedia = <String, List<CLEntity>>{};
    final noDate = <CLEntity>[];
    for (final entry in this) {
      final String formattedDate;
      if (entry.entityOriginalDate != null) {
        formattedDate =
            entry.entityOriginalDate!.toDisplayFormat(dataOnly: true);
      } else {
        formattedDate =
            '${entry.entityCreatedDate.toDisplayFormat(dataOnly: true)} '
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

  List<GalleryGroupCLEntity<CLEntity>> groupByTime(int columns) {
    final galleryGroups = <GalleryGroupCLEntity<CLEntity>>[];

    for (final entry in filterByDate().entries) {
      if (entry.value.length > columns) {
        final groups = entry.value.convertTo2D(columns);

        for (final (index, group) in groups.indexed) {
          galleryGroups.add(
            GalleryGroupCLEntity(
              group,
              label: (index == 0) ? entry.key : null,
              groupIdentifier: entry.key,
              chunkIdentifier: '${entry.key} $index',
            ),
          );
        }
      } else {
        galleryGroups.add(
          GalleryGroupCLEntity(
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

  List<GalleryGroupCLEntity<CLEntity>> group(int columns) {
    final galleryGroups = <GalleryGroupCLEntity<CLEntity>>[];

    for (final rows in convertTo2D(columns)) {
      galleryGroups.add(
        GalleryGroupCLEntity(
          rows,
          label: null,
          groupIdentifier: 'CLEntity',
          chunkIdentifier: 'CLEntity',
        ),
      );
    }
    return galleryGroups;
  }
}
