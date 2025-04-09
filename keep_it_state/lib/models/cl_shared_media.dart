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
  final List<StoreEntity> entries;
  final StoreEntity? collection;
  final UniversalMediaSource? type;

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;

  @override
  String toString() =>
      'CLSharedMedia(entries: $entries, collection: $collection, type: $type)';

  CLSharedMedia copyWith({
    List<StoreEntity>? entries,
    StoreEntity? collection,
    UniversalMediaSource? type,
  }) {
    return CLSharedMedia(
      entries: entries ?? this.entries,
      collection: collection ?? this.collection,
      type: type ?? this.type,
    );
  }

  Iterable<StoreEntity> get _stored => entries.where((e) => e.id != null);
  Iterable<StoreEntity> get _targetMismatch =>
      _stored.where((e) => e.parentId != collection?.id && !(e.data.isHidden));

  List<StoreEntity> get targetMismatch => _targetMismatch.toList();
  List<StoreEntity> get stored => _stored.toList();

  bool get hasTargetMismatchedItems => _targetMismatch.isNotEmpty;

  CLSharedMedia mergeMismatch() {
    final items = entries.map((e) => StoreEntity(
        entity: e.data.updateContent(
          isDeleted: false,
          parentId: () => collection?.id,
        ),
        store: e.store));
    return copyWith(entries: items.toList());
  }

  CLSharedMedia? removeMismatch() {
    final items = entries.where(
      (e) => e.parentId == collection?.id || (e.data.isHidden),
    );
    if (items.isEmpty) return null;

    return copyWith(entries: items.toList());
  }

  CLSharedMedia? remove(StoreEntity itemToRemove) {
    final items = entries.where((e) => e != itemToRemove);
    if (items.isEmpty) return null;

    return copyWith(entries: items.toList());
  }

  List<StoreEntity> itemsByType(CLMediaType type) =>
      entries.where((e) => e.data.mediaType == type).toList();

  List<StoreEntity> get videos => itemsByType(CLMediaType.video);
  List<StoreEntity> get images => itemsByType(CLMediaType.image);

  List<CLMediaType> get contentTypes =>
      Set<CLMediaType>.from(entries.map((e) => e.data.type)).toList();

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
