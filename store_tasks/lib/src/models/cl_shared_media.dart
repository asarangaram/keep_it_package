import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:store/store.dart';

import 'universal_media_source.dart';

@immutable
class CLSharedMedia {
  const CLSharedMedia({
    required this.entries,
    this.collection,
    this.type,
  });
  final ViewerEntities entries;
  final StoreEntity? collection;
  final StoreTaskType? type;

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;

  @override
  String toString() =>
      'CLSharedMedia(entries: $entries, collection: $collection, type: $type)';

  CLSharedMedia copyWith({
    ViewerEntities? entries,
    StoreEntity? collection,
    StoreTaskType? type,
  }) {
    return CLSharedMedia(
      entries: entries ?? this.entries,
      collection: collection ?? this.collection,
      type: type ?? this.type,
    );
  }

  Iterable<StoreEntity> get _stored =>
      entries.entities.cast<StoreEntity>().where((e) => e.id != null);
  Iterable<StoreEntity> get _targetMismatch =>
      _stored.where((e) => e.parentId != collection?.id && !e.data.isHidden);

  ViewerEntities get targetMismatch => ViewerEntities(_targetMismatch.toList());
  ViewerEntities get stored => ViewerEntities(_stored.toList());

  bool get hasTargetMismatchedItems => _targetMismatch.isNotEmpty;

  Future<CLSharedMedia> mergeMismatch() async {
    final items = <StoreEntity>[];
    for (final e in entries.entities.cast<StoreEntity>()) {
      await e.updateWith(
        isDeleted: () => false,
        parentId: () => collection?.id,
      );
    }
    return copyWith(entries: ViewerEntities(items.toList()));
  }

  CLSharedMedia? removeMismatch() {
    final items = entries.entities.cast<StoreEntity>().where(
          (e) => e.parentId == collection?.id || (e.data.isHidden),
        );
    if (items.isEmpty) return null;

    return copyWith(entries: ViewerEntities(items.toList()));
  }

  CLSharedMedia? remove(StoreEntity itemToRemove) {
    final items =
        entries.entities.cast<StoreEntity>().where((e) => e != itemToRemove);
    if (items.isEmpty) return null;

    return copyWith(entries: ViewerEntities(items.toList()));
  }

  ViewerEntities itemsByType(CLMediaType type) =>
      ViewerEntities(entries.entities
          .cast<StoreEntity>()
          .where((e) => e.data.mediaType == type)
          .toList());

  ViewerEntities get videos => itemsByType(CLMediaType.video);
  ViewerEntities get images => itemsByType(CLMediaType.image);

  List<CLMediaType> get contentTypes => Set<CLMediaType>.from(
      entries.entities.cast<StoreEntity>().map((e) => e.data.type)).toList();

  @override
  bool operator ==(covariant CLSharedMedia other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.entries, entries) &&
        other.collection == collection &&
        other.type == type;
  }

  @override
  int get hashCode => entries.hashCode ^ collection.hashCode ^ type.hashCode;
}
