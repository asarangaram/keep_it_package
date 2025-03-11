import 'dart:developer' as dev;
import 'dart:math' as math;

//import '../../app_logger.dart';

extension StoreExtensionOnString on String {
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
    dev.log('$prefix $this', name: 'printString');
  }

  String uptoLength(int N) {
    return substring(0, math.min(length, N));
  }

  String capitalizeFirstLetter() {
    if (isEmpty) return this; // Return the string as is if it's empty
    return '${this[0].toUpperCase()}${substring(1)}';
  }
}
