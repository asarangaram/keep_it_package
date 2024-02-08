import 'package:colan_widgets/colan_widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';

import 'collection.dart';

@immutable
class Items {
  const Items({
    required this.entries,
    required this.collection,
  });
  final List<CLMedia> entries;
  final Collection collection;

  bool get isEmpty => entries.isEmpty;
  bool get isNotEmpty => entries.isNotEmpty;
  @override
  String toString() => 'Items(entries: $entries, collection: $collection)';

  Items copyWith({
    List<CLMedia>? entries,
    Collection? collection,
  }) {
    return Items(
      entries: entries ?? this.entries,
      collection: collection ?? this.collection,
    );
  }

  @override
  bool operator ==(covariant Items other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.entries, entries) && other.collection == collection;
  }

  @override
  int get hashCode => entries.hashCode ^ collection.hashCode;

  List<CLMedia> itemsByType(CLMediaType type) =>
      entries.where((e) => e.type == type).toList();

  List<CLMedia> get videos => itemsByType(CLMediaType.video);
  List<CLMedia> get images => itemsByType(CLMediaType.video);

  List<CLMediaType> get contentTypes =>
      Set<CLMediaType>.from(entries.map((e) => e.type)).toList();
}
