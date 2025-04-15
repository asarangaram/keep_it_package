import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/selector.dart';
import '../../models/viewer_entity_mixin.dart';

class SelectorNotifier extends StateNotifier<CLSelector> {
  SelectorNotifier(List<ViewerEntityMixin> entities)
      : super(CLSelector(entities: entities));

  void select(List<ViewerEntityMixin> candidates) {
    state = state.select(candidates);
  }

  void deselect(List<ViewerEntityMixin> candidates) {
    state = state.deselect(candidates);
  }

  void toggle(List<ViewerEntityMixin> candidates) {
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
