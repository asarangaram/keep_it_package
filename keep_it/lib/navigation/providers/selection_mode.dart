// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/navigation/providers/active_collection.dart';

@immutable
class SelectionMode {
  final bool canSelect;
  final bool isSelecting;
  const SelectionMode({
    this.canSelect = false,
    this.isSelecting = false,
  });

  SelectionMode copyWith({
    bool? canSelect,
    bool? isSelecting,
  }) {
    return SelectionMode(
      canSelect: canSelect ?? this.canSelect,
      isSelecting: isSelecting ?? this.isSelecting,
    );
  }

  @override
  bool operator ==(covariant SelectionMode other) {
    if (identical(this, other)) return true;

    return other.canSelect == canSelect && other.isSelecting == isSelecting;
  }

  @override
  int get hashCode => canSelect.hashCode ^ isSelecting.hashCode;
}

class SelectionModeNotifier extends StateNotifier<SelectionMode> {
  SelectionModeNotifier({required SelectionMode selectionMode})
      : super(selectionMode);

  void toggleSelection() {
    state = state.copyWith(isSelecting: !state.isSelecting);
  }
}

final selectionModeProvider =
    StateNotifierProvider<SelectionModeNotifier, SelectionMode>((ref) {
  final collectionId = ref.watch(activeCollectionProvider);
  return SelectionModeNotifier(
    selectionMode: SelectionMode(
      canSelect: collectionId != null,
    ),
  );
});
