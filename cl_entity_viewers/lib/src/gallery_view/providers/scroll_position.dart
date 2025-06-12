import 'package:flutter_riverpod/flutter_riverpod.dart';

final tabScrollPositionProvider =
    StateProvider.family<double, String>((ref, identifier) {
  return 0;
});
