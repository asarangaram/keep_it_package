import 'package:cl_media_tools/cl_media_tools.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'cl_entity.dart';

class NotNullValues {}

@immutable
class StoreQuery<T> {
  const StoreQuery(this.storeIdentity, this.map);
  final String? storeIdentity;
  final Map<String, dynamic> map;

  @override
  bool operator ==(covariant StoreQuery<T> other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other.storeIdentity == storeIdentity && mapEquals(other.map, map);
  }

  @override
  int get hashCode => storeIdentity.hashCode ^ map.hashCode;

  StoreQuery<T> copyWith({
    String? storeIdentity,
    Map<String, dynamic>? map,
  }) {
    return StoreQuery<T>(
      storeIdentity ?? this.storeIdentity,
      map ?? this.map,
    );
  }

  @override
  String toString() => 'StoreQuery(storeIdentity: $storeIdentity, map: $map)';
}

abstract class EntityTable {
  Future<CLEntity?> upsert<CLEntity>(
    CLEntity item, {
    CLMediaFile? content,
  });

  Future<void> delete<CLEntity>(CLEntity item);
  Future<CLEntity?> get<CLEntity>([covariant StoreQuery<CLEntity>? query]);
  Future<List<CLEntity>> getAll<CLEntity>([
    covariant StoreQuery<CLEntity>? query,
  ]);
}

class Shortcuts {
  static StoreQuery<CLEntity> mediaQuery(String storeIdentity, CLEntity media) {
    return StoreQuery<CLEntity>(storeIdentity, {
      if (media.id != null)
        'id': media.id
      else if (media.isCollection)
        'label': media.label
      else
        'md5': media.md5,
      'isCollection': media.isCollection,
    });
  }
}
