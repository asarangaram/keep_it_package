import 'package:intl/intl.dart';

extension UtilExtensionOnDateTime on DateTime {
  String toDisplayFormat({bool dataOnly = false}) {
    if (dataOnly) {
      return DateFormat('dd MMMM yyyy').format(this);
    } else {
      return DateFormat('dd MMMM yyyy HH:mm:ss').format(this);
    }
  }
}
