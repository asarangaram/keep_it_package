import 'package:content_store/search_filters/models/filters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/filter/base_filter.dart';

class FiltersNotifier extends StateNotifier<SearchFilters> {
  FiltersNotifier()
      : super(
          SearchFilters(
            defaultTextSearchFilter: SearchFilters.textSearchFilter,
          ),
        );

  void toggleEdit() => state = state.toggleEdit();

  void enableEdit() => state = state.enableEdit();
  void disableEdit() => state = state.disableEdit();

  void updateFilter(CLFilter<CLMedia> filter, String key, dynamic value) =>
      state = state.updateFilter(filter.name, key, value);

  void updateDefautTextSearchFilter(
    String query,
  ) {
    state = state.copyWith(
      defaultTextSearchFilter:
          state.defaultTextSearchFilter.update('query', query),
    );
  }

  void addFilter(CLFilter<CLMedia> filter) => state = state.addFilter(filter);

  void removeFilter(CLFilter<CLMedia> filter) =>
      state = state.removeFilter(filter.name);
  void clearFilters() => state = state.clearFilters();
}

final filtersProvider =
    StateNotifierProvider<FiltersNotifier, SearchFilters>((ref) {
  return FiltersNotifier();
});
