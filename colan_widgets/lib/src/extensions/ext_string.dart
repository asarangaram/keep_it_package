import 'dart:math';

import '../app_logger.dart';

extension ColonExtensionOnString on String {
  bool isURL() {
    try {
      final uri = Uri.parse(this);
      // Check if the scheme is non-empty to ensure it's a valid URL
      return uri.scheme.isNotEmpty;
    } catch (e) {
      return false; // Parsing failed, not a valid URL
    }
  }

  void printString({String prefix = ''}) {
    _infoLogger('$prefix $this');
  }

  String uptoLength(int N) {
    return substring(0, min(length, N));
  }

  String capitalizeFirstLetter() {
    if (isEmpty) return this; // Return the string as is if it's empty
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}

bool _disableInfoLogger = true;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
