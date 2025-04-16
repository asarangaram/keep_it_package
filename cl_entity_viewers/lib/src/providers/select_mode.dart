import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tab_identifier.dart';

class SelectModeNotifier extends StateNotifier<bool> {
  SelectModeNotifier() : super(false);

  enable() => state = true;
  disable() => state = false;
  toggle() => state = !state;
}

final selectModeProvider =
    StateNotifierProvider.family<SelectModeNotifier, bool, ViewIdentifier>(
        (ref, identifier) {
  return SelectModeNotifier();
});
