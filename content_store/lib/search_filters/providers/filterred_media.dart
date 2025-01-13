import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'filters.dart';

final filterredMediaProvider =
    StateProvider.family<CLMedias, CLMedias>((ref, incoming) {
  final searchfilters = ref.watch(filtersProvider);

  var filterred = searchfilters.defaultTextSearchFilter.apply(incoming.entries);

  for (final filter in searchfilters()) {
    if (filter.enabled) {
      filterred = filter.apply(filterred);
    }
  }

  return CLMedias(filterred);
});
