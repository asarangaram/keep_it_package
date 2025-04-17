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
  int get hashCode =>
      map.entries.fold(storeIdentity.hashCode, (previousValue, element) {
        return previousValue ^ element.key.hashCode ^ element.value.hashCode;
      });

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
