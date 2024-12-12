import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'filters.dart';

final filterredMediaProvider =
    StateProvider.family<CLMedias, CLMedias>((ref, incoming) {
  final searchfilters = ref.watch(filtersProvider);

  var filterred = incoming.entries;

  for (final filter in searchfilters()) {
    filterred = filter.apply(filterred);
  }

  return CLMedias(filterred);
});
