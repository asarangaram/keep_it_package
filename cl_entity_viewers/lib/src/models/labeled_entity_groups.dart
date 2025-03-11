import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'cl_entities.dart';
import 'gallery_group.dart';

@immutable
class LabelledEntityGroups {
  const LabelledEntityGroups({
    required this.name,
    required this.galleryGroups,
  });
  final String name;
  final List<GalleryGroupCLEntity<CLEntity>> galleryGroups;

  LabelledEntityGroups copyWith({
    String? name,
    List<GalleryGroupCLEntity<CLEntity>>? galleryGroups,
  }) {
    return LabelledEntityGroups(
      name: name ?? this.name,
      galleryGroups: galleryGroups ?? this.galleryGroups,
    );
  }

  @override
  bool operator ==(covariant LabelledEntityGroups other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.name == name && listEquals(other.galleryGroups, galleryGroups);
  }

  @override
  int get hashCode => name.hashCode ^ galleryGroups.hashCode;

  @override
  String toString() => 'TabData(name: $name, galleryGroups: $galleryGroups)';
}
