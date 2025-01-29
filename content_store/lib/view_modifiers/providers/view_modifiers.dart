import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    PopOverMenuItemsNotifier, PopOverMenuItems, String>((ref, identifier) {
  final items = [
    ref.watch(mediaFiltersProvider(identifier)),
    GroupBy(),
  ];
  return PopOverMenuItemsNotifier(items);
});

class GroupBy implements ViewModifier {
  @override
  bool get isActive => false;

  @override
  String get name => 'Group By';
}
