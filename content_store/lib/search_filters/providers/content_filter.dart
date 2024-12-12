import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/filter/base_filter.dart';
import '../models/filter/ddmmyyyy_filter.dart';
import '../models/filter/enum_filter.dart';

final filterredMediaProvider =
    StateProvider.family<CLMedias, CLMedias>((ref, incoming) {
  final filters = ref.watch(filtersProvider);

  var filterred = incoming.entries;
  for (final filter in filters) {
    filterred = filter.apply(filterred);
  }

  return CLMedias(filterred);
});

class Filters2Notifier extends StateNotifier<List<CLFilter<CLMedia>>> {
  Filters2Notifier()
      : super([
          EnumFilter<CLMedia, CLMediaType>(
            name: 'Media Types',
            labels: {
              for (var e in [CLMediaType.image, CLMediaType.video]) e: e.name,
            },
            fieldSelector: (media) => media.type,
            enabled: false,
          ),
          DDMMYYYYFilter(
            name: 'Created Date',
            fieldSelector: (media) => media.createdDate,
            enabled: false,
          ),
          /* DDMMYYYYFilter(
            name: 'Updated Date',
            fieldSelector: (media) => media.updatedDate,
            enabled: false,
          ), */
        ]);

  void updateFilter(CLFilter<CLMedia> filter, String key, dynamic value) {
    state = state
        .map((e) => e.name == filter.name ? e.update(key, value) : e)
        .toList();
  }
}

final filters2NotifierProvider =
    StateNotifierProvider<Filters2Notifier, List<CLFilter<CLMedia>>>((ref) {
  return Filters2Notifier();
});

final filtersProvider = filters2NotifierProvider;
