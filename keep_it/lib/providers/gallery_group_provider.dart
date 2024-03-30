import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final groupedItemsProvider =
    StateProvider.family<List<GalleryGroup<CLMedia>>, List<CLMedia>>(
        (ref, items) {
  final galleryGroups = <GalleryGroup<CLMedia>>[];
  for (final entry in items.filterByDate().entries) {
    galleryGroups.add(
      GalleryGroup(
        entry.value,
        label: entry.key,
      ),
    );
  }
  return galleryGroups;
});
