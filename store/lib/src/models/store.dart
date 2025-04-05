import 'package:meta/meta.dart';
import 'package:store/store.dart';

@immutable
class StoreQuery<T> {
  const StoreQuery(this.map);
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
  Future<T?> get<T>([StoreQuery<T>? query]);
  Future<List<T>> getAll<T>([StoreQuery<T>? query]);
  Future<void> reloadStore();
  Future<void> dispose();
}

class Shortcuts {
  static StoreQuery<CLEntity> mediaQuery(CLEntity media) {
    return StoreQuery<CLEntity>({
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
