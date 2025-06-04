import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectModeNotifier extends StateNotifier<bool> {
  SelectModeNotifier() : super(false);

  bool enable() => state = true;
  bool disable() => state = false;
  bool toggle() => state = !state;
}

final selectModeProvider =
    StateNotifierProvider<SelectModeNotifier, bool>((ref) {
  throw Exception("Must overide");
  // return SelectModeNotifier();
});
