import 'package:yet_another_date_picker/yet_another_date_picker.dart';

import 'base_filter.dart';

class DDMMYYYYFilter<T> extends BaseFilter<T, DateTime> {
  const DDMMYYYYFilter({
    required super.name,
    required super.fieldSelector,
    required super.enabled,
    this.ddmmyyyy,
  }) : super(filterType: FilterType.ddmmyyyyFilter);

  final DDMMYYYY? ddmmyyyy;

  @override
  List<T> apply(List<T> items) {
    if (!enabled) return items;
    if (ddmmyyyy == null) return items;
    final filterred = items.where((item) {
      final date = fieldSelector(item);
      if (ddmmyyyy == null) {
        return true;
      } else {
        final dd = ddmmyyyy!.dd;
        final mm = ddmmyyyy!.mm + 1;
        final yyyy = ddmmyyyy!.yyyy;

        return (dd == null || dd == date.day) &&
            (mm == date.month) &&
            (yyyy == null || yyyy == date.year);
      }
    }).toList();

    return filterred;
  }

  @override
  DDMMYYYYFilter<T> update(
    String key,
    dynamic value,
  ) {
    final DDMMYYYYFilter<T> updated;
    if ('ddmmyyyy' == key) {
      final ddmmyyyy = value as DDMMYYYY;
      updated = DDMMYYYYFilter<T>(
        fieldSelector: fieldSelector,
        enabled: true,
        name: name,
        ddmmyyyy: ddmmyyyy,
      );
    } else if ('enable' == key) {
      final enable = value as bool;
      if (enable == enabled) {
        updated = this;
      } else {
        updated = DDMMYYYYFilter<T>(
          fieldSelector: fieldSelector,
          enabled: enable,
          name: name,
          ddmmyyyy: ddmmyyyy ?? DDMMYYYY.fromDateTime(DateTime.now()),
        );
      }
    } else {
      throw Exception('unsupported update');
    }

    return updated;
  }

  @override
  bool operator ==(covariant DDMMYYYYFilter<T> other) {
    if (identical(this, other)) return true;

    return other.ddmmyyyy == ddmmyyyy && super == other;
  }

  @override
  int get hashCode => ddmmyyyy.hashCode ^ super.hashCode;

  @override
  String toString() => [
        'DDMMYYYYFilter ($name) is $enabled',
        if (enabled) '$ddmmyyyy',
        '[$hashCode]',
      ].join(' ');

  @override
  bool get isActive => enabled && ddmmyyyy != null;
}
