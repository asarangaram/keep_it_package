import 'package:flutter/foundation.dart';

import 'base_filter.dart';

@immutable
class BooleanFilter<T> extends BaseFilter<T, bool> {
  const BooleanFilter(
      {required super.name,
      required super.fieldSelector,
      required this.value,
      required super.enabled,
      required super.isByPassed})
      : super(filterType: FilterType.booleanFilter);

  final bool value;

  @override
  List<T> apply(List<T> items) {
    return items
        .where((item) => isByPassed(item) || fieldSelector(item) == value)
        .toList();
  }

  @override
  BooleanFilter<T> update(
    String key,
    dynamic value,
  ) {
    throw UnimplementedError();
  }

  @override
  bool operator ==(covariant BooleanFilter<T> other) {
    if (identical(this, other)) return true;

    return other.value == value && super == other;
  }

  @override
  int get hashCode => value.hashCode ^ super.hashCode;

  @override
  bool get isActive => throw UnimplementedError();
}
