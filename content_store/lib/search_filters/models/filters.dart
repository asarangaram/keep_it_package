import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../../view_modifiers/models/view_modifier.dart';
import 'filter/base_filter.dart';
import 'filter/string_filter.dart';

enum MediaAvailability { local, coLan, synced }

@immutable
class SearchFilters<T> implements ViewModifier {
  const SearchFilters({
    required this.defaultTextSearchFilter,
    this.filters,
    this.editing = false,
  });
  final List<CLFilter<T>>? filters;
  final StringFilter<T> defaultTextSearchFilter;
  final bool editing;
  @override
  bool operator ==(covariant SearchFilters<T> other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.filters, filters) &&
        other.defaultTextSearchFilter == defaultTextSearchFilter &&
        other.editing == editing;
  }

  @override
  int get hashCode =>
      filters.hashCode ^ defaultTextSearchFilter.hashCode ^ editing.hashCode;

  SearchFilters<T> copyWith({
    StringFilter<T>? defaultTextSearchFilter,
    ValueGetter<List<CLFilter<T>>?>? filters,
    bool? editing,
  }) {
    return SearchFilters(
      defaultTextSearchFilter:
          defaultTextSearchFilter ?? this.defaultTextSearchFilter,
      filters: filters != null ? filters.call() : this.filters,
      editing: editing ?? this.editing,
    );
  }

  SearchFilters<T> addFilter(CLFilter<T> filter) {
    /// No filter with same name can be added twice.
    /// First we check if the filter already exists.
    if (filters != null && filters!.map((e) => e.name).contains(filter.name)) {
      return this;
    }
    final updated = [if (filters != null) ...filters!, filter];

    return copyWith(filters: () => updated);
  }

  SearchFilters<T> removeFilter(String filterName) {
    if (filters == null) return this;
    return copyWith(
      filters: () => filters!.where((e) => e.name != filterName).toList(),
    );
  }

  SearchFilters<T> updateFilter(
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

  SearchFilters<T> updateDefautTextSearchFilter(
    String query,
  ) {
    return copyWith(
      defaultTextSearchFilter: defaultTextSearchFilter.update('query', query),
    );
  }

  SearchFilters<T> clearFilters() {
    return copyWith(
      filters: () => filters?.map((e) => e.update('clear', null)).toList(),
    );
  }

  List<CLFilter<T>> call() => filters?.where((e) => e.enabled).toList() ?? [];

  SearchFilters<T> toggleEdit() => editing ? disableEdit() : enableEdit();
  SearchFilters<T> enableEdit() => copyWith(
        editing: true,
        filters: () => filters?.map((e) => e.update('enable', true)).toList(),
      );
  SearchFilters<T> disableEdit() => copyWith(
        editing: false,
        filters: () => filters?.map((e) => e.update('enable', false)).toList(),
      );

  @override
  bool get isActive => filters?.any((e) => e.isActive) ?? false;

  bool get isTextFilterActive => defaultTextSearchFilter.isActive;

  @override
  String get name => 'Filters';

  List<T> apply(List<T> incoming) {
    var filterred = defaultTextSearchFilter.apply(incoming);
    if (filters != null) {
      for (final filter in filters!) {
        if (filter.enabled) {
          filterred = filter.apply(filterred);
        }
      }
    }
    return filterred;
  }
}
