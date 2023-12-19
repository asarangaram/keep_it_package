import 'package:flutter_riverpod/flutter_riverpod.dart';

class SelectItem {
  final dynamic collection;
  final bool isSelected;

  SelectItem({required this.collection, this.isSelected = false});

  SelectItem copyWith({
    dynamic collection,
    bool? isSelected,
  }) {
    return SelectItem(
      collection: collection ?? this.collection,
      isSelected: isSelected ?? this.isSelected,
    );
  }

  @override
  bool operator ==(covariant SelectItem other) {
    if (identical(this, other)) return true;

    return other.collection == collection && other.isSelected == isSelected;
  }

  @override
  int get hashCode => collection.hashCode ^ isSelected.hashCode;

  SelectItem toggleSelection() {
    return copyWith(isSelected: !isSelected);
  }

  @override
  String toString() =>
      'SelectCollection(collection: $collection, isSelected: $isSelected)';
}

class SelectItemNotifier extends StateNotifier<SelectItem> {
  SelectItemNotifier(super.selectCollection);

  toggleSelection() {
    state = state.toggleSelection();
  }
}

final selectItemProvider =
    StateNotifierProvider.family<SelectItemNotifier, SelectItem, dynamic>(
        (ref, collection) {
  return SelectItemNotifier(SelectItem(collection: collection));
});

final selectedItemsProvider =
    StateProvider.family<List, List>((ref, collections) {
  List cList = [];
  for (var c in collections) {
    SelectItem sc = ref.watch(selectItemProvider(c));
    if (sc.isSelected) cList.add(c);
  }
  return cList;
});
