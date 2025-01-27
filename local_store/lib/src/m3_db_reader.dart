import 'package:local_store/src/m3_db_queries.dart';
import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'm3_db_query.dart';

@immutable
class DBReader extends StoreReader {
  DBReader(this.tx);
  final SqliteWriteContext tx;

  @override
  Future<T?> read<T>(StoreQuery<T> query) {
    return (query as DBQuery<T>).read(tx);
  }

  @override
  Future<List<T>> readMultiple<T>(StoreQuery<T> query) {
    return (query as DBQuery<T>).readMultiple(tx);
  }

  @override
  StoreQuery<T> getQuery<T>(DBQueries query, {List<Object?>? parameters}) =>
      Queries.getQuery(query, parameters: parameters);
}
