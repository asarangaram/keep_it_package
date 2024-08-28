import 'dart:math';

extension StoreExtensionOnString on String {
  String uptoLength(int N) {
    return substring(0, min(length, N));
  }
}
