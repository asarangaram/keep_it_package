import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupedItemsProvider =
    StateProvider.family<List<GalleryGroup<CLMedia>>, List<CLMedia>>(
        (ref, items) {
  final galleryGroups = <GalleryGroup<CLMedia>>[];
  for (final entry in items.filterByDate().entries) {
    if (entry.value.length > 20) {
      final groups = entry.value.convertTo2D(20);

      galleryGroups
        ..add(
          GalleryGroup(
            groups[0],
            label: entry.key,
          ),
        )
        ..addAll(groups.sublist(1).map(GalleryGroup.new));
    } else {
      galleryGroups.add(
        GalleryGroup(
          entry.value,
          label: entry.key,
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
  galleryGroups.add(GalleryGroup(items));
  return galleryGroups;
});
