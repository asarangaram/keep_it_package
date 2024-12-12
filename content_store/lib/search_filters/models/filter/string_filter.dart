// ignore_for_file: public_member_api_docs, sort_constructors_first

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
    return items.where((item) => fieldSelector(item).contains(query)).toList();
  }

  @override
  StringFilter<T> update(
    String key,
    dynamic value, {
    String? updateType,
  }) {
    throw UnimplementedError();
  }

  @override
  bool operator ==(covariant StringFilter<T> other) {
    if (identical(this, other)) return true;

    return other.query == query && super == other;
  }

  @override
  int get hashCode => query.hashCode ^ super.hashCode;
}
