import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

@immutable
class MapDiff {
  const MapDiff({
    required this.added,
    required this.deleted,
    required this.changed,
  });
  factory MapDiff.scan(
    Map<String, Object?> old,
    Map<String, Object?> newMap,
  ) {
    final added = <String, dynamic>{};
    final deleted = <String, dynamic>{};
    final changed = <String, dynamic>{};

    // Create a set of all keys from both maps
    final allKeys = <String>{...old.keys, ...newMap.keys};

    // Iterate over all unique keys
    for (final key in allKeys) {
      final oldValue = old[key];
      final newValue = newMap[key];

      if (!old.containsKey(key)) {
        // If key is only in newMap, it's an addition
        added[key] = newValue;
      } else if (!newMap.containsKey(key)) {
        // If key is only in old, it's a deletion
        deleted[key] = oldValue;
      } else if (!deepCompare(oldValue, newValue)) {
        // If the key exists in both but values differ, it's modified
        changed[key] = newValue;
      }
    }
    return MapDiff(added: added, deleted: deleted, changed: changed);
  }
  factory MapDiff.log(
    Map<String, Object?> old,
    Map<String, Object?> newMap,
  ) {
    final added = <String, dynamic>{};
    final deleted = <String, dynamic>{};
    final changed = <String, dynamic>{};

    // Create a set of all keys from both maps
    final allKeys = <String>{...old.keys, ...newMap.keys};

    // Iterate over all unique keys
    for (final key in allKeys) {
      final oldValue = old[key];
      final newValue = newMap[key];

      if (!old.containsKey(key)) {
        // If key is only in newMap, it's an addition
        added[key] = newValue;
      } else if (!newMap.containsKey(key)) {
        // If key is only in old, it's a deletion
        deleted[key] = oldValue;
      } else if (!deepCompare(oldValue, newValue)) {
        // If the key exists in both but values differ, it's modified
        changed[key] = {'oldValue': oldValue, 'newValue': newValue};
      }
    }
    return MapDiff(added: added, deleted: deleted, changed: changed);
  }
  static bool deepCompare(dynamic value1, dynamic value2) {
    const equality = DeepCollectionEquality();
    return equality.equals(value1, value2);
  }

  final Map<String, Object?> added;
  final Map<String, Object?> deleted;
  final Map<String, Object?> changed;

  Map<String, dynamic> get diffMap => {...added, ...changed};
  Map<String, dynamic> get diffMapFull => {...added, ...changed, ...deleted};

  bool get hasChange => diffMapFull.isNotEmpty;

  @override
  String toString() =>
      'MapDiff(added: $added, deleted: $deleted, changed: $changed)';

  @override
  bool operator ==(covariant MapDiff other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return mapEquals(other.added, added) &&
        mapEquals(other.deleted, deleted) &&
        mapEquals(other.changed, changed);
  }

  @override
  int get hashCode => added.hashCode ^ deleted.hashCode ^ changed.hashCode;
}
