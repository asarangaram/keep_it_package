import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'viewer_entity_mixin.dart';

// ignore_for_file: public_member_api_docs, sort_constructors_first
/* import 'package:store/src/extensions/ext_datetime.dart';
import 'package:store/src/extensions/ext_list.dart';

import 'gallery_group.dart'; */

@immutable
class ViewerEntities {
  const ViewerEntities(this.entities);
  final List<ViewerEntity> entities;

  ViewerEntities copyWith({List<ViewerEntity>? entities}) {
    return ViewerEntities(entities ?? this.entities);
  }

  @override
  String toString() => 'ViewerEntities(entities: $entities)';

  @override
  bool operator ==(covariant ViewerEntities other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return listEquals(other.entities, entities);
  }

  @override
  int get hashCode => entities.hashCode;

  int get length => entities.length;

  bool get isEmpty => entities.isEmpty;
  bool get isNotEmpty => entities.isNotEmpty;
}
