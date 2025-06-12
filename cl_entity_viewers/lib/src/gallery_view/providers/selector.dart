import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/models/viewer_entity_mixin.dart';
import '../models/selector.dart';

class SelectorNotifier extends StateNotifier<CLSelector> {
  SelectorNotifier(List<ViewerEntity> entities)
      : super(CLSelector(entities: entities));

  void select(List<ViewerEntity> candidates) {
    state = state.select(candidates);
  }

  void deselect(List<ViewerEntity> candidates) {
    state = state.deselect(candidates);
  }

  void toggle(List<ViewerEntity> candidates) {
    if (state.isSelected(candidates) == SelectionStatus.selectedNone) {
      select(candidates);
    } else {
      deselect(candidates);
    }
  }

  void clear() {
    state = state.clear();
  }

  void updateSelection(List<ViewerEntity>? candidates, {bool? deselect}) {
    if (candidates == null) {
      clear();
    } else if (deselect == null) {
      toggle(candidates);
    } else if (deselect) {
      this.deselect(candidates);
    } else {
      select(candidates);
    }
  }
}

final selectorProvider =
    StateNotifierProvider<SelectorNotifier, CLSelector>((ref) {
  throw Exception('Not in the scope !');
});
