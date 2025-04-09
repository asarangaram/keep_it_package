import 'package:store/store.dart';

extension IndexExtonList<T> on List<T> {
  List<T> replaceNthEntry(int index, T newValue) {
    if (index < 0 || index >= length) {
      throw IndexError.withLength(index, length);
    }

    return [
      ...sublist(0, index), // Elements before the index
      newValue, // New value at the index
      ...sublist(index + 1), // Elements after the index
    ];
  }
}

extension Filter on List<CLEntity> {
  Map<String, List<CLEntity>> filterByDate() {
    final filterredMedia = <String, List<CLEntity>>{};
    final noDate = <CLEntity>[];
    for (final entry in this) {
      final String formattedDate;
      if (entry.createDate != null) {
        formattedDate = entry.createDate!.toDisplayFormat(dataOnly: true);
      } else {
        formattedDate = '${entry.addedDate.toDisplayFormat(dataOnly: true)} '
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

  List<GalleryGroupStoreEntity<CLEntity>> groupByDate() {
    final galleryGroups = <GalleryGroupStoreEntity<CLEntity>>[];
    for (final entry in filterByDate().entries) {
      if (entry.value.length > 20) {
        final groups = entry.value.convertTo2D(20);

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
}
