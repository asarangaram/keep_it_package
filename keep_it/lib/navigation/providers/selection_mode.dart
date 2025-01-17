import 'package:flutter_riverpod/flutter_riverpod.dart';

final selectModeProvider =
    StateProvider.family<bool, String>((ref, identifier) {
  return false;
});
