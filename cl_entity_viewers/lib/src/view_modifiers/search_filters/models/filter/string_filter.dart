import 'package:flutter/foundation.dart';

import 'base_filter.dart';

@immutable
class StringFilter<T> extends BaseFilter<T, String> {
  const StringFilter({
    required super.name,
    required super.fieldSelector,
    required this.query,
    required super.enabled,
  }) : super(filterType: FilterType.stringFilter);

  final String query;

  @override
  List<T> apply(List<T> items) {
    return items
        .where((item) => fieldSelector(item).contains(query.toLowerCase()))
        .toList();
  }

  @override
  StringFilter<T> update(
    String key,
    dynamic value, {
    String? updateType,
  }) {
    return switch (key) {
      'enable' => _enable(value as bool),
      'query' => _query(value as String),
      'clear' => _query(''),
      _ => throw UnimplementedError(),
    };
  }

  StringFilter<T> _enable(bool value) {
    return StringFilter<T>(
      name: name,
      fieldSelector: fieldSelector,
      query: query,
      enabled: value,
    );
  }

  StringFilter<T> _query(String value) {
    return StringFilter<T>(
      name: name,
      fieldSelector: fieldSelector,
      query: value,
      enabled: enabled,
    );
  }

  @override
  bool operator ==(covariant StringFilter<T> other) {
    if (identical(this, other)) return true;

    return other.query == query && super == other;
  }

  @override
  int get hashCode => query.hashCode ^ super.hashCode;

  @override
  bool get isActive => enabled && query.isNotEmpty;
}
