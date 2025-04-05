import 'package:meta/meta.dart';

@immutable
class StoreQuery<T> {
  StoreQuery(Map<String, dynamic> map) : map = Map.unmodifiable(map);
  final Map<String, dynamic> map;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is StoreQuery && _mapEquals(other.map, map);
  }

  @override
  int get hashCode => map.entries
      .fold(0, (prev, e) => prev ^ e.key.hashCode ^ e.value.hashCode);

  bool _mapEquals(Map<String, dynamic> a, Map<String, dynamic> b) {
    if (a.length != b.length) return false;
    for (final key in a.keys) {
      if (!b.containsKey(key) || a[key] != b[key]) return false;
    }
    return true;
  }
}

@immutable
abstract class Store {
  const Store();

  Future<T?> upsert<T>(T item);
  Future<void> delete<T>(T item);
  Future<T?> get<T>(StoreQuery<T>? query);
  Future<List<T>> getAll<T>(StoreQuery<T>? query);

  void reloadStore();
  void dispose();
}
