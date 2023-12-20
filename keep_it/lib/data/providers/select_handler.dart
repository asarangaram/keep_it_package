import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectableItem {
  final dynamic collection;
  final bool isSelected;

  SelectableItem({required this.collection, this.isSelected = false});

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

  toggleSelection() {
    state = state.toggleSelection();
  }

  select() {
    state = state.select();
  }

  deselect() {
    state = state.deselect();
  }
}

final selectableItemProvider = StateNotifierProvider.family<
    SelectableItemNotifier, SelectableItem, dynamic>((ref, item) {
  return SelectableItemNotifier(SelectableItem(collection: item));
});

final selectableItemsSelectedItemsProvider =
    StateProvider.family<List, List>((ref, items) {
  List cList = [];
  for (var c in items) {
    SelectableItem sc = ref.watch(selectableItemProvider(c));
    if (sc.isSelected) cList.add(sc.collection);
  }
  return cList;
});
