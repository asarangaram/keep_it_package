// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:store/store.dart';

import 'filter/base_filter.dart';
import 'filter/ddmmyyyy_filter.dart';
import 'filter/enum_filter.dart';
import 'filter/string_filter.dart';

enum MediaAvailability { local, coLan, synced }

@immutable
class SearchFilters {
  const SearchFilters({this.filters, this.editing = false});
  final List<CLFilter<CLMedia>>? filters;
  final bool editing;
  @override
  bool operator ==(covariant SearchFilters other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.filters, filters);
  }

  @override
  int get hashCode => filters.hashCode;

  SearchFilters copyWith({
    ValueGetter<List<CLFilter<CLMedia>>?>? filters,
    bool? editing,
  }) {
    return SearchFilters(
      filters: filters != null ? filters.call() : this.filters,
      editing: editing ?? this.editing,
    );
  }

  SearchFilters addFilter(CLFilter<CLMedia> filter) {
    /// No filter with same name can be added twice.
    /// First we check if the filter already exists.
    if (filters != null && filters!.map((e) => e.name).contains(filter.name)) {
      return this;
    }
    final updated = [if (filters != null) ...filters!, filter];

    return copyWith(filters: () => updated);
  }

  SearchFilters removeFilter(String filterName) {
    if (filters == null) return this;
    return copyWith(
      filters: () => filters!.where((e) => e.name != filterName).toList(),
    );
  }

  SearchFilters updateFilter(
    String filterName,
    String key,
    dynamic value,
  ) {
    if (filters == null) return this;

    return copyWith(
      filters: () => filters!
          .map((e) => e.name == filterName ? e.update(key, value) : e)
          .toList(),
    );
  }

  SearchFilters clearFilters() {
    return copyWith(filters: () => null);
  }

  List<String> get availableFilters {
    return filters?.map((e) => e.name).toList() ?? [];
  }

  List<CLFilter<CLMedia>> call() =>
      filters?.where((e) => e.enabled).toList() ?? [];

  SearchFilters toggleEdit() => editing ? disableEdit() : enableEdit();
  SearchFilters enableEdit() => copyWith(
        editing: true,
        filters: () => filters?.map((e) => e.update('enable', true)).toList(),
      );
  SearchFilters disableEdit() => copyWith(
        editing: false,
        filters: () => filters?.map((e) => e.update('enable', false)).toList(),
      );

  static final List<CLFilter<CLMedia>> allFilters = [
    EnumFilter<CLMedia, CLMediaType>(
      name: 'Search By MediaType',
      labels: {
        for (var e in [CLMediaType.image, CLMediaType.video]) e: e.name,
      },
      fieldSelector: (media) => media.type,
      enabled: true,
    ),
    EnumFilter<CLMedia, MediaAvailability>(
      name: 'Search By Location',
      labels: {
        for (var e in MediaAvailability.values) e: e.name,
      },
      fieldSelector: (media) {
        if (media.hasServerUID && media.isMediaCached) {
          return MediaAvailability.synced;
        } else if (media.hasServerUID) {
          return MediaAvailability.coLan;
        }
        return MediaAvailability.local;
      },
      enabled: true,
    ),
    DDMMYYYYFilter(
      name: 'Search by Date',
      fieldSelector: (media) => media.createdDate,
      enabled: true,
    ),
    // Consider to add Collection name, notes and tags
    StringFilter(
      name: 'TextSearch',
      fieldSelector: (media) => [media.name, media.ref].join(),
      query: '',
      enabled: true,
    ),
  ];

  Map<String, CLFilter<CLMedia>> get allFiltersMap =>
      {for (final e in allFilters) e.name: e};

  Map<String, CLFilter<CLMedia>> get unusedFiltersMap => Map.fromEntries(
        allFiltersMap.entries
            .where((entry) => !availableFilters.contains(entry.key)),
      );

  List<CLFilter<CLMedia>> get unusedFilters => List.from(
        allFilters.where((e) => !availableFilters.contains(e.name)),
      );
}
