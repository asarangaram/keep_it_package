import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import '../../common/models/viewer_entity_mixin.dart';

@immutable
class ViewerEntityGroups {
  const ViewerEntityGroups({
    required this.name,
    required this.galleryGroups,
  });
  final String name;
  final List<ViewerEntityGroup<ViewerEntityMixin>> galleryGroups;

  ViewerEntityGroups copyWith({
    String? name,
    List<ViewerEntityGroup<ViewerEntityMixin>>? galleryGroups,
  }) {
    return ViewerEntityGroups(
      name: name ?? this.name,
      galleryGroups: galleryGroups ?? this.galleryGroups,
    );
  }

  @override
  bool operator ==(covariant ViewerEntityGroups other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.name == name && listEquals(other.galleryGroups, galleryGroups);
  }

  @override
  int get hashCode => name.hashCode ^ galleryGroups.hashCode;

  @override
  String toString() => 'TabData(name: $name, galleryGroups: $galleryGroups)';
}
