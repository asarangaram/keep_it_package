import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/selector.dart';

class SelectorNotifier extends StateNotifier<CLSelector> {
  SelectorNotifier(List<CLEntity> entities)
      : super(CLSelector(entities: entities));

  void select(List<CLEntity> candidates) {
    state = state.select(candidates);
  }

  void deselect(List<CLEntity> candidates) {
    state = state.deselect(candidates);
  }

  void toggle(List<CLEntity> candidates) {
    if (state.isSelected(candidates) == SelectionStatus.selectedNone) {
      select(candidates);
    } else {
      deselect(candidates);
    }
  }

  void clear() {
    state = state.clear();
  }
}

final selectorProvider =
    StateNotifierProvider<SelectorNotifier, CLSelector>((ref) {
  throw Exception('Not in the scope !');
});
