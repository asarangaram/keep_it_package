import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'm3_db_query.dart';

final Map<Type, Map<String, dynamic>> runtimeTypeMapper = {
  CLEntity: {
    'table': 'Entity',
    'fromMap': CLEntity.fromMap,
  },
};

final Map<Type, dynamic> fromMapMethods = {
  CLEntity: CLEntity.fromMap,
};

@immutable
class DBReader extends StoreReader {
  DBReader(this.tx);
  final SqliteWriteContext tx;

  String getTableName<T>() {
    final tableName = runtimeTypeMapper[T]?['table'] as String?;
    if (tableName == null) {
      throw Exception('No table name mapping found for type $T');
    }
    return tableName;
  }

  Future<StoreQuery<T>> formQuery<T>(
    Map<String, dynamic>? queryMap, {
    Set<String> triggerOnTables = const {},
  }) async {
    final tableName = getTableName<T>();

    final columnInfo = await tx.execute('PRAGMA table_info($tableName)');
    final validColumns = columnInfo.map((row) => row['name'] as String).toSet();

    // Step 2: Build WHERE clause
    final whereParts = <String>[];
    final params = <dynamic>[];

    if (queryMap != null) {
      for (final query in queryMap.entries) {
        final key = query.key;
        final value = query.value;
        if (validColumns.contains(key)) {
          if (value == null) {
            whereParts.add('$key IS NULL');
          } else if (value is List && value.isNotEmpty) {
            final placeholders = List.filled(value.length, '?').join(', ');
            whereParts.add('$key IN ($placeholders)');
            params.addAll(value);
          } else {
            whereParts.add('$key = ?');
            params.add(value);
          }
        }
      }
    }

    final whereClause =
        whereParts.isNotEmpty ? 'WHERE ${whereParts.join(' AND ')}' : '';
    final sql = 'SELECT * FROM $tableName $whereClause';

    return DBQuery<T>.map(
      sql: sql,
      parameters: params,
      triggerOnTables: {...triggerOnTables, tableName},
    );
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

  @override
  Future<T?> get<T>(
    Map<String, dynamic>? queryMap, {
    required T? Function(Map<String, dynamic>) fromMap,
  }) {
    final q = formQuery<T>(queryMap);
    return (q as DBQuery<T>).get(tx);
  }

  @override
  Future<List<T>> getAll<T>(
    Map<String, dynamic>? queryMap, {
    required T? Function(Map<String, dynamic>) fromMap,
  }) {
    final q = formQuery<T>(queryMap);
    return (q as DBQuery<T>).getAll(tx);
  }
}
