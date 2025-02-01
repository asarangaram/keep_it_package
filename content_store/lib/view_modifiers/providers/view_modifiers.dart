import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it_state/keep_it_state.dart';

import '../../media_grouper/providers/media_grouper.dart';
import '../../search_filters/providers/media_filters.dart';
import '../models/view_modifier.dart';
import '../models/view_modifiers.dart';

class PopOverMenuItemsNotifier extends StateNotifier<PopOverMenuItems> {
  PopOverMenuItemsNotifier(List<ViewModifier> items)
      : super(PopOverMenuItems(items: items));

  void updateCurr(String name) {
    state = state.copyWith(
      currIndex: () => state.items.indexWhere((e) => e.name == name),
    );
  }
}

final popOverMenuProvider = StateNotifierProvider.family<
    PopOverMenuItemsNotifier,
    PopOverMenuItems,
    TabIdentifier>((ref, tabIdentifier) {
  final items = [
    ref.watch(mediaFiltersProvider(tabIdentifier.view.parentID)),
    ref.watch(
      groupMethodProvider(tabIdentifier.tabId),
    ),
  ];
  return PopOverMenuItemsNotifier(items);
});
