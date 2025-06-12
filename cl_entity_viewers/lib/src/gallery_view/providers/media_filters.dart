import 'package:cl_media_tools/cl_media_tools.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/viewer_entity_mixin.dart';
import '../models/filter/base_filter.dart';
import '../models/filter/ddmmyyyy_filter.dart';
import '../models/filter/enum_filter.dart';
import '../models/filter/string_filter.dart';
import '../models/filter/filters.dart';

class MediaFiltersNotifier
    extends StateNotifier<SearchFilters<ViewerEntityMixin>> {
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

  void updateFilter(
    CLFilter<ViewerEntityMixin> filter,
    String key,
    dynamic value,
  ) =>
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

  Map<String, CLFilter<ViewerEntityMixin>> get unusedFiltersMap =>
      Map.fromEntries(
        allFiltersMap.entries
            .where((entry) => !availableFilters.contains(entry.key)),
      );

  List<CLFilter<ViewerEntityMixin>> get unusedFilters => List.from(
        allFilters.where((e) => !availableFilters.contains(e.name)),
      );
}

final mediaFiltersProvider = StateNotifierProvider<MediaFiltersNotifier,
    SearchFilters<ViewerEntityMixin>>((ref) {
  return MediaFiltersNotifier();
});

final List<CLFilter<ViewerEntityMixin>> allFilters = List.unmodifiable([
  EnumFilter<ViewerEntityMixin, CLMediaType>(
    name: 'Search By MediaType',
    labels: {
      for (var e in [CLMediaType.image, CLMediaType.video]) e: e.name,
    },
    fieldSelector: (media) => media.mediaType,
    isByPassed: (media) => media.isCollection,
    enabled: true,
  ),
  EnumFilter<ViewerEntityMixin, MediaAvailability>(
    name: 'Search By Location',
    labels: {
      for (var e in MediaAvailability.values) e: e.name,
    },
    fieldSelector: (media) {
      return MediaAvailability.local;
    },
    isByPassed: (media) => media.isCollection,
    enabled: true,
  ),
  DDMMYYYYFilter<ViewerEntityMixin>(
    name: 'Search by Date',
    fieldSelector: (media) => media.createDate ?? media.updatedDate,
    isByPassed: (media) => media.isCollection,
    enabled: false,
  ),
]);

Map<String, CLFilter<ViewerEntityMixin>> get allFiltersMap =>
    Map.unmodifiable({for (final e in allFilters) e.name: e});

final StringFilter<ViewerEntityMixin> textSearchFilter = StringFilter(
  name: 'TextSearch',
  fieldSelector: (media) => media.searchableTexts,
  isByPassed: (media) => media.isCollection,
  query: '',
  enabled: true,
);

final filterredMediaProvider =
    StateProvider.family<List<ViewerEntityMixin>, List<ViewerEntityMixin>>(
        (ref, entities) {
  final mediaFilters = ref.watch(mediaFiltersProvider);
  return mediaFilters.apply(entities);
});
