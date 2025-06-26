import 'package:meta/meta.dart';
import 'package:store/store.dart';

@immutable
class DBQuery<T> {
  const DBQuery(this.requestTarget);
  factory DBQuery.fromStoreQuery(
    // ignore: avoid_unused_constructor_parameters will be used later
    String path,
    Set<String> validKeys, [
    StoreQuery<T>? query,
  ]) {
    if (query != null) {
      for (final query in query.map.entries) {
        final key = query.key;
        final value = query.value;
        if (validKeys.contains(key)) {
          switch (value) {
            case null:
              throw UnimplementedError();
            case (final List<dynamic> _) when value.isNotEmpty:
              throw UnimplementedError();
            case (final NotNullValues _):
              throw UnimplementedError();
            default:
              throw UnimplementedError();
          }
        }
      }
    }
    throw UnimplementedError();
  }
  final String requestTarget;
}
