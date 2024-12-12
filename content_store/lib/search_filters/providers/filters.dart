import 'package:content_store/search_filters/models/filters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/filter/base_filter.dart';
import '../models/filter/ddmmyyyy_filter.dart';
import '../models/filter/enum_filter.dart';

class FiltersNotifier extends StateNotifier<SearchFilters> {
  FiltersNotifier() : super(const SearchFilters());

  void toggleEdit() => state = state.toggleEdit();

  void enableEdit() => state = state.enableEdit();
  void disableEdit() => state = state.disableEdit();

  void updateFilter(CLFilter<CLMedia> filter, String key, dynamic value) =>
      state = state.updateFilter(filter.name, key, value);

  void addFilter(CLFilter<CLMedia> filter) => state = state.addFilter(filter);

  void removeFilter(CLFilter<CLMedia> filter) =>
      state = state.removeFilter(filter.name);

  final Map<String, CLFilter<CLMedia>> availableFilters = {
    'Search By MediaType': EnumFilter<CLMedia, CLMediaType>(
      name: 'Media Types',
      labels: {
        for (var e in [CLMediaType.image, CLMediaType.video]) e: e.name,
      },
      fieldSelector: (media) => media.type,
      enabled: false,
    ),
    'Search by Date': DDMMYYYYFilter(
      name: 'Created Date',
      fieldSelector: (media) => media.createdDate,
      enabled: false,
    ),
  };

  Map<String, CLFilter<CLMedia>> get unusedFilters => Map.fromEntries(
        availableFilters.entries
            .where((entry) => !state.availableFilters.contains(entry.key)),
      );
}

final filtersProvider =
    StateNotifierProvider<FiltersNotifier, SearchFilters>((ref) {
  return FiltersNotifier();
});
