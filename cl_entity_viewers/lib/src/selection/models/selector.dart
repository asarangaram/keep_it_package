import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import '../../entity/models/viewer_entity_mixin.dart';

enum SelectionStatus { selectedNone, selectedPartial, selectedAll }

@immutable
class CLSelector {
  const CLSelector({
    required this.entities,
    this.items = const {},
  });
  final List<ViewerEntityMixin> entities;
  final Set<ViewerEntityMixin> items;

  CLSelector copyWith({
    List<ViewerEntityMixin>? entities,
    Set<ViewerEntityMixin>? items,
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

  SelectionStatus isSelected(List<ViewerEntityMixin> candidates) {
    if (candidates.every(items.contains)) {
      return SelectionStatus.selectedAll;
    }
    if (candidates.any(items.contains)) {
      return SelectionStatus.selectedPartial;
    }
    return SelectionStatus.selectedNone;
  }

  List<ViewerEntityMixin> selectedItems(List<ViewerEntityMixin> candidates) {
    return candidates.where(items.contains).toList();
  }

  CLSelector select(List<ViewerEntityMixin> candidates) {
    return copyWith(items: {...items, ...candidates});
  }

  CLSelector deselect(List<ViewerEntityMixin> candidates) {
    return copyWith(items: {...items.where((e) => !candidates.contains(e))});
  }

  CLSelector toggle(List<ViewerEntityMixin> candidates) {
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
      'items: ${items.map((e) => e.id).toList()})';
}
