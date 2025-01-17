// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

enum SelectionStatus { selectedNone, selectedPartial, selectedAll }

@immutable
class CLSelector {
  final List<CLEntity> entities;
  final Set<CLEntity> items;
  const CLSelector({
    required this.entities,
    this.items = const {},
  });

  CLSelector copyWith({
    List<CLEntity>? entities,
    Set<CLEntity>? items,
  }) {
    return CLSelector(
      entities: entities ?? this.entities,
      items: items ?? this.items,
    );
  }

  @override
  bool operator ==(covariant CLSelector other) {
    if (identical(this, other)) return true;
    final collectionEquals = const DeepCollectionEquality().equals;

    return collectionEquals(other.entities, entities) &&
        collectionEquals(other.items, items);
  }

  @override
  int get hashCode => entities.hashCode ^ items.hashCode;

  SelectionStatus isSelected(List<CLEntity> candidates) {
    if (candidates.every(items.contains)) {
      return SelectionStatus.selectedAll;
    }
    if (candidates.any(items.contains)) {
      return SelectionStatus.selectedPartial;
    }
    return SelectionStatus.selectedNone;
  }

  List<CLEntity> selectedItems(List<CLEntity> candidates) {
    return candidates.where(items.contains).toList();
  }

  CLSelector select(List<CLEntity> candidates) {
    return copyWith(items: {...items, ...candidates});
  }

  CLSelector deselect(List<CLEntity> candidates) {
    return copyWith(items: {...items.where((e) => !candidates.contains(e))});
  }

  CLSelector toggle(List<CLEntity> candidates) {
    if (isSelected(candidates) == SelectionStatus.selectedNone) {
      return select(candidates);
    }
    return deselect(candidates);
  }

  CLSelector clear() {
    return CLSelector(entities: entities);
  }

  int get count => items.length;

  @override
  String toString() => 'CLSelector(entities: ${entities.length}, '
      'items: ${items.map((e) => e.entityId).toList()})';
}
