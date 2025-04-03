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
  final List<CLMedia> entries;
  final CLMedia? collection;
  final UniversalMediaSource? type;

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;

  @override
  String toString() =>
      'CLSharedMedia(entries: $entries, collection: $collection, type: $type)';

  CLSharedMedia copyWith({
    List<CLMedia>? entries,
    CLMedia? collection,
    UniversalMediaSource? type,
  }) {
    return CLSharedMedia(
      entries: entries ?? this.entries,
      collection: collection ?? this.collection,
      type: type ?? this.type,
    );
  }

  Iterable<CLMedia> get _stored => entries.where((e) => e.id != null);
  Iterable<CLMedia> get _targetMismatch =>
      _stored.where((e) => e.parentId != collection?.id && !(e.isHidden));

  List<CLMedia> get targetMismatch => _targetMismatch.toList();
  List<CLMedia> get stored => _stored.toList();

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

  CLSharedMedia? remove(CLMedia itemToRemove) {
    final items = entries.where((e) => e != itemToRemove);
    if (items.isEmpty) return null;

    return copyWith(entries: items.toList());
  }

  List<CLMedia> itemsByType(CLMediaType type) =>
      entries.where((e) => e.mediaType == type).toList();

  List<CLMedia> get videos => itemsByType(CLMediaType.video);
  List<CLMedia> get images => itemsByType(CLMediaType.image);

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
