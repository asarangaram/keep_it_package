
import 'package:flutter/foundation.dart';

enum FilterType {
  stringFilter,
  booleanFilter,
  dateFilter,
  ddmmyyyyFilter,
  enumFilter
}

@immutable
abstract class CLFilter<T> {
  const CLFilter({
    required this.name,
    required this.filterType,
    required this.enabled,
  });
  final String name;
  final FilterType filterType;
  final bool enabled;
  List<T> apply(List<T> items);
  CLFilter<T> update(String key, dynamic value);

  @override
  bool operator ==(covariant CLFilter<T> other) {
    if (identical(this, other)) return true;

    return other.name == name &&
        other.filterType == filterType &&
        other.enabled == enabled;
  }

  @override
  int get hashCode => name.hashCode ^ filterType.hashCode ^ enabled.hashCode;
}

@immutable
abstract class BaseFilter<T, E> extends CLFilter<T> {
  const BaseFilter({
    required super.name,
    required this.fieldSelector,
    required super.filterType,
    required super.enabled,
  });
  final E Function(T) fieldSelector;
  @override
  List<T> apply(List<T> items);

  @override
  bool operator ==(covariant BaseFilter<T, E> other) {
    if (identical(this, other)) return true;

    return other.fieldSelector == fieldSelector && super == other;
  }

  @override
  int get hashCode => fieldSelector.hashCode ^ super.hashCode;
}
