import 'package:local_store/src/m3_db_queries.dart';
import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'm3_db_query.dart';

@immutable
class DBReader extends StoreReader {
  DBReader(this.tx, {this.tableName = 'Entity'});
  final SqliteWriteContext tx;
  final String tableName;

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

  Future<StoreQuery<T>> formQuery<T>(
    Map<String, dynamic>? queryMap,
    Set<String> triggerOnTables,
  ) async {
    // Step 1: Get valid columns from the table
    final columnInfo = await tx.execute('PRAGMA table_info($tableName)');
    final validColumns = columnInfo.map((row) => row['name'] as String).toSet();

    // Step 2: Build WHERE clause
    final whereParts = <String>[];
    final params = <dynamic>[];

    if (queryMap != null) {
      queryMap.forEach((key, value) {
        if (!validColumns.contains(key)) return; // skip unknown keys

        if (value is List && value.isNotEmpty) {
          final placeholders = List.filled(value.length, '?').join(', ');
          whereParts.add('$key IN ($placeholders)');
          params.addAll(value);
        } else if (value != null) {
          whereParts.add('$key = ?');
          params.add(value);
        }
      });
    }

    final whereClause =
        whereParts.isNotEmpty ? 'WHERE ${whereParts.join(' AND ')}' : '';
    final sql = 'SELECT * FROM $tableName $whereClause';

    return DBQuery<T>(
      sql: sql,
      parameters: params,
      triggerOnTables: triggerOnTables,
    );
  }

  @override
  Future<List<CLEntity>> storeQuery(
    Map<String, dynamic>? queryMap,
  ) async {
    return [];
  }

  Future<List<String>> getColumnNames(
    SqliteWriteContext db,
    String tableName,
  ) async {
    final result = await db.execute('PRAGMA table_info($tableName)');

    // PRAGMA returns: cid, name, type, notnull, dflt_value, pk
    // We'll map column name to data type
    final columns = <String>[
      for (final row in result) row['name'] as String,
    ];

    return columns;
  }
}
