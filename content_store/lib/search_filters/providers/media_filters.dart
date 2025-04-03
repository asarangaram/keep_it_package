import 'package:content_store/search_filters/models/filters.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';
import 'package:store/store.dart';

import '../models/filter/base_filter.dart';
import '../models/filter/ddmmyyyy_filter.dart';
import '../models/filter/enum_filter.dart';
import '../models/filter/string_filter.dart';

class MediaFiltersNotifier extends StateNotifier<SearchFilters<CLEntity>> {
  MediaFiltersNotifier()
      : super(
          SearchFilters(
            defaultTextSearchFilter: textSearchFilter,
            filters: List.from(allFilters),
          ),
        );

  void toggleEdit() => state = state.toggleEdit();

  void enableEdit() => state = state.enableEdit();
  void disableEdit() => state = state.disableEdit();

  void updateFilter(CLFilter<CLEntity> filter, String key, dynamic value) =>
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
  void clearFilters() => state = state.clearFilters();

  List<String> get availableFilters {
    return state.filters?.map((e) => e.name).toList() ?? [];
  }

  Map<String, CLFilter<CLEntity>> get unusedFiltersMap => Map.fromEntries(
        allFiltersMap.entries
            .where((entry) => !availableFilters.contains(entry.key)),
      );

  List<CLFilter<CLEntity>> get unusedFilters => List.from(
        allFilters.where((e) => !availableFilters.contains(e.name)),
      );
}

final mediaFiltersProvider = StateNotifierProvider.family<MediaFiltersNotifier,
    SearchFilters<CLEntity>, String>((ref, identifier) {
  return MediaFiltersNotifier();
});

final List<CLFilter<CLEntity>> allFilters = List.unmodifiable([
  EnumFilter<CLEntity, CLMediaType>(
    name: 'Search By MediaType',
    labels: {
      for (var e in [CLMediaType.image, CLMediaType.video]) e: e.name,
    },
    fieldSelector: (media) => media.mediaType,
    enabled: true,
  ),
  EnumFilter<CLEntity, MediaAvailability>(
    name: 'Search By Location',
    labels: {
      for (var e in MediaAvailability.values) e: e.name,
    },
    fieldSelector: (media) {
      return MediaAvailability.local;
    },
    enabled: true,
  ),
  DDMMYYYYFilter<CLEntity>(
    name: 'Search by Date',
    fieldSelector: (media) => media.addedDate,
    enabled: false,
  ),
]);

Map<String, CLFilter<CLEntity>> get allFiltersMap =>
    Map.unmodifiable({for (final e in allFilters) e.name: e});

final StringFilter<CLEntity> textSearchFilter = StringFilter(
  name: 'TextSearch',
  fieldSelector: (media) =>
      [media.label, media.description].join(' ').toLowerCase(),
  query: '',
  enabled: true,
);

final filterredMediaProvider = StateProvider.family<List<CLEntity>,
    MapEntry<ViewIdentifier, List<CLEntity>>>((ref, mediaMap) {
  final mediaFilters = ref.watch(mediaFiltersProvider(mediaMap.key.parentID));
  return mediaFilters.apply(mediaMap.value);
});
