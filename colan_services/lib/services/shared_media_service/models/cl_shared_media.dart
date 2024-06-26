import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/foundation.dart';

@immutable
class CLSharedMedia {
  const CLSharedMedia({required this.entries, this.collection});
  final List<CLMedia> entries;
  final Collection? collection;

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;

  @override
  String toString() => 'CLMediaList(entries: $entries, '
      'collection: $collection)';

  CLSharedMedia copyWith({
    List<CLMedia>? entries,
    Collection? collection,
  }) {
    return CLSharedMedia(
      entries: entries ?? this.entries,
      collection: collection ?? this.collection,
    );
  }

  Iterable<CLMedia> get _stored => entries.where((e) => e.id != null);
  Iterable<CLMedia> get _targetMismatch => _stored
      .where((e) => e.collectionId != collection?.id && !(e.isHidden ?? false));

  List<CLMedia> get targetMismatch => _targetMismatch.toList();
  List<CLMedia> get stored => _stored.toList();

  bool get hasTargetMismatchedItems => _targetMismatch.isNotEmpty;

  CLSharedMedia mergeMismatch() {
    final items = entries.map((e) => e.setCollectionId(collection?.id));
    return copyWith(entries: items.toList());
  }

  CLSharedMedia? removeMismatch() {
    final items = entries.where(
      (e) => e.collectionId == collection?.id || (e.isHidden ?? false),
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
      entries.where((e) => e.type == type).toList();

  List<CLMedia> get videos => itemsByType(CLMediaType.video);
  List<CLMedia> get images => itemsByType(CLMediaType.image);

  List<CLMediaType> get contentTypes =>
      Set<CLMediaType>.from(entries.map((e) => e.type)).toList();
}
