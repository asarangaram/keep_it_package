import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectModeNotifier extends StateNotifier<bool> {
  SelectModeNotifier() : super(false);

  enable() => state = true;
  disable() => state = false;
  toggle() => state = !state;
}

final selectModeProvider =
    StateNotifierProvider<SelectModeNotifier, bool>((ref) {
  throw Exception("Must overide");
  // return SelectModeNotifier();
});
