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
  final List<CLEntity> entries;
  final CLEntity? collection;
  final UniversalMediaSource? type;

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;

  @override
  String toString() =>
      'CLSharedMedia(entries: $entries, collection: $collection, type: $type)';

  CLSharedMedia copyWith({
    List<CLEntity>? entries,
    CLEntity? collection,
    UniversalMediaSource? type,
  }) {
    return CLSharedMedia(
      entries: entries ?? this.entries,
      collection: collection ?? this.collection,
      type: type ?? this.type,
    );
  }

  Iterable<CLEntity> get _stored => entries.where((e) => e.id != null);
  Iterable<CLEntity> get _targetMismatch =>
      _stored.where((e) => e.parentId != collection?.id && !(e.isHidden));

  List<CLEntity> get targetMismatch => _targetMismatch.toList();
  List<CLEntity> get stored => _stored.toList();

  bool get hasTargetMismatchedItems => _targetMismatch.isNotEmpty;

  CLSharedMedia mergeMismatch() {
    final items = entries.map(
      (e) => e.updateContent(
        isDeleted: () => false,
        collectionId: () => collection?.id,
      ),
    );
    return copyWith(entries: items.toList());
  }

  CLSharedMedia? removeMismatch() {
    final items = entries.where(
      (e) => e.parentId == collection?.id || (e.isHidden),
    );
    if (items.isEmpty) return null;

    return copyWith(entries: items.toList());
  }

  CLSharedMedia? remove(CLEntity itemToRemove) {
    final items = entries.where((e) => e != itemToRemove);
    if (items.isEmpty) return null;

    return copyWith(entries: items.toList());
  }

  List<CLEntity> itemsByType(CLMediaType type) =>
      entries.where((e) => e.mediaType == type).toList();

  List<CLEntity> get videos => itemsByType(CLMediaType.video);
  List<CLEntity> get images => itemsByType(CLMediaType.image);

  List<CLMediaType> get contentTypes =>
      Set<CLMediaType>.from(entries.map((e) => e.type)).toList();

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
