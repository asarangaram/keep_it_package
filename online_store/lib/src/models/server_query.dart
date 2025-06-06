import 'package:meta/meta.dart';
import 'package:store/store.dart';

@immutable
class ServerQuery<T> {
  const ServerQuery(this.requestTarget);
  factory ServerQuery.fromStoreQuery(
    String path,
    Set<String> validKeys, [
    StoreQuery<T>? storeQuery,
  ]) {
    Map<String, String> keyValuePair = {};
    if (storeQuery != null) {
      for (final query in storeQuery.map.entries) {
        final key = query.key;
        final value = query.value;
        if (validKeys.contains(key)) {
          switch (value) {
            case null:
              if (key == 'parentId') {
                keyValuePair[key] = "0";
              }
              break;
            case (final List<dynamic> _) when value.isNotEmpty:
              keyValuePair[key] = value.join(',');

            case (final NotNullValues _):
              keyValuePair[key] = "Unset";
            default:
              keyValuePair[key] = value.toString();
          }
        }
      }
    }

    final queryString =
        keyValuePair.entries.map((e) => "${e.key}=${e.value}").join('&');
    final String requestTarget;
    if (queryString.isEmpty) {
      requestTarget = path;
    } else {
      requestTarget = "$path?$queryString";
    }

    return ServerQuery(requestTarget);
  }
  final String requestTarget;
}
