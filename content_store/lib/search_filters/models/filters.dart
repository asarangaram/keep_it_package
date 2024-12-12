// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:store/store.dart';

import 'filter/base_filter.dart';

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

  List<String> get availableFilters {
    return filters?.map((e) => e.name).toList() ?? [];
  }

  List<CLFilter<CLMedia>> call() =>
      filters?.where((e) => e.enabled).toList() ?? [];

  SearchFilters toggleEdit() => copyWith(editing: !editing);
  SearchFilters enableEdit() => copyWith(editing: true);
  SearchFilters disableEdit() => copyWith(editing: false);
}
