import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

@immutable
class MediaViewerState {
  const MediaViewerState({
    this.entities = const [],
    this.currentIndex = 0,
    this.lockScreen = false,
  });
  final List<ViewerEntityMixin> entities;
  final int currentIndex;
  final bool lockScreen;

  MediaViewerState copyWith({
    List<ViewerEntityMixin>? entities,
    int? currentIndex,
  }) {
    return MediaViewerState(
      entities: entities ?? this.entities,
      currentIndex: currentIndex ?? this.currentIndex,
    );
  }

  @override
  bool operator ==(covariant MediaViewerState other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.entities, entities) &&
        other.currentIndex == currentIndex;
  }

  @override
  int get hashCode => entities.hashCode ^ currentIndex.hashCode;

  @override
  String toString() =>
      'MediaViewerState(entities: $entities, currentIndex: $currentIndex)';
}
