import 'package:content_store/search_filters/models/filters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/filter/base_filter.dart';
import '../models/filter/filter_instances.dart';

class FiltersNotifier extends StateNotifier<SearchFilters> {
  FiltersNotifier()
      : super(
          SearchFilters(
            defaultTextSearchFilter: textSearchFilter,
            filters: List.from(allFilters),
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

  /* void addFilter(CLFilter<CLMedia> filter) => state = state.addFilter(filter);

  void removeFilter(CLFilter<CLMedia> filter) =>
      state = state.removeFilter(filter.name); */
  /* void clearFilters() => state = state.clearFilters(); */

  List<String> get availableFilters {
    return state.filters?.map((e) => e.name).toList() ?? [];
  }

  Map<String, CLFilter<CLMedia>> get unusedFiltersMap => Map.fromEntries(
        allFiltersMap.entries
            .where((entry) => !availableFilters.contains(entry.key)),
      );

  List<CLFilter<CLMedia>> get unusedFilters => List.from(
        allFilters.where((e) => !availableFilters.contains(e.name)),
      );
}

final filtersProvider =
    StateNotifierProvider<FiltersNotifier, SearchFilters>((ref) {
  return FiltersNotifier();
});
