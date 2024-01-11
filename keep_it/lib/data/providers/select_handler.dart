import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

@immutable
class SelectableItem {
  const SelectableItem({required this.collection, this.isSelected = false});
  final dynamic collection;
  final bool isSelected;

  SelectableItem copyWith({
    bool? isSelected,
  }) {
    return SelectableItem(
      collection: collection,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(covariant SelectableItem other) {
    if (identical(this, other)) return true;

    return other.collection == collection && other.isSelected == isSelected;
  }

  @override
  int get hashCode => collection.hashCode ^ isSelected.hashCode;

  SelectableItem toggleSelection() => copyWith(isSelected: !isSelected);
  SelectableItem select() => copyWith(isSelected: true);
  SelectableItem deselect() => copyWith(isSelected: false);
}

class SelectableItemNotifier extends StateNotifier<SelectableItem> {
  SelectableItemNotifier(super.selectableItem);

  void toggleSelection() {
    state = state.toggleSelection();
  }

  void select() {
    state = state.select();
  }

  void deselect() {
    state = state.deselect();
  }
}

final selectableItemProvider = StateNotifierProvider.family<
    SelectableItemNotifier, SelectableItem, dynamic>((ref, item) {
  return SelectableItemNotifier(SelectableItem(collection: item));
});

final selectableItemsSelectedItemsProvider =
    StateProvider.family<List<dynamic>, List<dynamic>>((ref, items) {
  final cList = <dynamic>[];
  for (final c in items) {
    final sc = ref.watch(selectableItemProvider(c));
    if (sc.isSelected) cList.add(sc.collection);
  }
  return cList;
});
