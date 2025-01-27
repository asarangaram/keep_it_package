import 'base_filter.dart';

class DateFilter<T> extends BaseFilter<T, DateTime> {
  const DateFilter({
    required super.name,
    required super.fieldSelector,
    required super.enabled,
    this.startDate,
    this.endDate,
  }) : super(filterType: FilterType.dateFilter);

  final DateTime? startDate;
  final DateTime? endDate;

  @override
  List<T> apply(List<T> items) {
    if (startDate == null || endDate == null) {
      return items;
    }
    return items.where((item) {
      final date = fieldSelector(item);
      return date.isAfter(startDate!) && date.isBefore(endDate!);
    }).toList();
  }

  @override
  DateFilter<T> update(
    String key,
    dynamic value,
  ) {
    throw UnimplementedError();
  }

  @override
  bool operator ==(covariant DateFilter<T> other) {
    if (identical(this, other)) return true;

    return other.startDate == startDate &&
        other.endDate == endDate &&
        super == other;
  }

  @override
  int get hashCode => startDate.hashCode ^ endDate.hashCode ^ super.hashCode;
}
