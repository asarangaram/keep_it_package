import 'package:intl/intl.dart';

extension ExtDATETIME on DateTime {
  String toDisplayFormat({bool dataOnly = false}) {
    if (dataOnly) {
      return DateFormat('dd MMMM yyyy').format(this);
    } else {
      return DateFormat('dd MMMM yyyy HH:mm:ss').format(this);
    }
  }
}

extension ExtDATETIMENullable on DateTime? {
  String? toDisplayFormat({bool dataOnly = false}) {
    if (this != null) return this!.toDisplayFormat(dataOnly: dataOnly);
    return null;
  }
}
