import 'package:intl/intl.dart';

extension ExtDATETIME on DateTime? {
  String? toSQL() {
    if (this == null) {
      return null;
    }
    return DateFormat('yyyy-MM-dd HH:mm:ss').format(this!);
  }
}
