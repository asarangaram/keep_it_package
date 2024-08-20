// ignore_for_file: public_member_api_docs, sort_constructors_first
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
        deleted[key] = null;
      } else if (!deepCompare(oldValue, newValue)) {
        // If the key exists in both but values differ, it's modified
        changed[key] = newValue;
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
}
