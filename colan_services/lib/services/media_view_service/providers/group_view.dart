import 'package:colan_services/internal/extensions/list.dart';
import 'package:colan_widgets/colan_widgets.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

final groupedItemsProvider =
    StateProvider.family<List<GalleryGroup<CLMedia>>, List<CLMedia>>(
        (ref, medias) {
  final galleryGroups = <GalleryGroup<CLMedia>>[];
  for (final entry in medias.filterByDate().entries) {
    if (entry.value.length > 20) {
      final groups = entry.value.convertTo2D(20);

      for (final (index, group) in groups.indexed) {
        galleryGroups.add(
          GalleryGroup(
            group,
            label: (index == 0) ? entry.key : null,
            groupIdentifier: entry.key,
            chunkIdentifier: '${entry.key} $index',
          ),
        );
      }
    } else {
      galleryGroups.add(
        GalleryGroup(
          entry.value,
          label: entry.key,
          groupIdentifier: entry.key,
          chunkIdentifier: entry.key,
        ),
      );
    }
  }
  return galleryGroups;
});

final singleGroupItemProvider =
    StateProvider.family<List<GalleryGroup<CLMedia>>, List<CLMedia>>(
        (ref, items) {
  final galleryGroups = <GalleryGroup<CLMedia>>[];
  if (items.isEmpty) return galleryGroups;
  galleryGroups.add(
    GalleryGroup(
      items,
      groupIdentifier: 'Single Group',
      chunkIdentifier: 'Single Group',
      label: null,
    ),
  );
  return galleryGroups;
});
