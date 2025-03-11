import 'package:intl/intl.dart';

extension ExtDATETIME on DateTime {
  /*  String toSQL() {
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(this);
  } */

  String toDisplayFormat({bool dataOnly = false}) {
    if (dataOnly) {
      return DateFormat('dd MMMM yyyy').format(this);
    } else {
      return DateFormat('dd MMMM yyyy HH:mm:ss').format(this);
    }
  }
}

extension ExtDATETIMENullable on DateTime? {
  /* String? toSQL() {
    if (this == null) {
      return null;
    }
    return this!.toSQL();
  } */
}
