import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:store/store.dart';

import '../../view_modifiers/models/view_modifier.dart';
import 'filter/base_filter.dart';
import 'filter/string_filter.dart';

enum MediaAvailability { local, coLan, synced }

@immutable
class SearchFilters implements ViewModifier {
  const SearchFilters({
    required this.defaultTextSearchFilter,
    this.filters,
    this.editing = false,
  });
  final List<CLFilter<CLMedia>>? filters;
  final StringFilter<CLMedia> defaultTextSearchFilter;
  final bool editing;
  @override
  bool operator ==(covariant SearchFilters other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.filters, filters) &&
        other.defaultTextSearchFilter == defaultTextSearchFilter &&
        other.editing == editing;
  }

  @override
  int get hashCode =>
      filters.hashCode ^ defaultTextSearchFilter.hashCode ^ editing.hashCode;

  SearchFilters copyWith({
    StringFilter<CLMedia>? defaultTextSearchFilter,
    ValueGetter<List<CLFilter<CLMedia>>?>? filters,
    bool? editing,
  }) {
    return SearchFilters(
      defaultTextSearchFilter:
          defaultTextSearchFilter ?? this.defaultTextSearchFilter,
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

  SearchFilters updateDefautTextSearchFilter(
    String query,
  ) {
    return copyWith(
      defaultTextSearchFilter: defaultTextSearchFilter.update('query', query),
    );
  }

  SearchFilters clearFilters() {
    return copyWith(filters: () => null);
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

  @override
  bool get isActive => filters?.any((e) => e.isActive) ?? false;

  @override
  String get name => 'Filters';
}
