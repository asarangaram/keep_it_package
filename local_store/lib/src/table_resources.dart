import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'm3_db_query.dart';
import 'm4_db_exec.dart';

Map<Type, dynamic> tableResources = {CLEntity: DBResources<CLEntity>()};

@immutable
class DBResources<T> {
  factory DBResources() {
    final mapper = runtimeTypeMapper[T];
    if (mapper == null) {
      throw Exception('No table name mapping found for type $T');
    }
    return DBResources._(
      table: mapper['table'] as String,
      fromMap: mapper['fromMap'] as T Function(Map<String, dynamic> map),
      toMap: mapper['toMap'] as Map<String, dynamic> Function(T obj),
      readBack: mapper['readBack'] as Future<T?> Function(
        SqliteWriteContext tx,
        T obj,
      ),
      uniqueColumn: (CLEntity obj) {
        return [
          'id',
          if (obj.isCollection) 'label' else 'md5',
        ];
      } as List<String> Function(T obj),
      writer: DBExec(
        table: mapper['table'] as String,
        toMap: mapper['toMap'] as Map<String, dynamic> Function(T obj),
        readBack: mapper['readBack'] as Future<T?> Function(
          SqliteWriteContext tx,
          T obj,
        ),
      ),
    );
  }
  const DBResources._({
    required this.table,
    required this.fromMap,
    required this.toMap,
    required this.readBack,
    required this.writer,
    required this.uniqueColumn,
  });
  final String table;
  final T Function(Map<String, dynamic> map)? fromMap;
  final Map<String, dynamic> Function(T obj) toMap;
  final Future<T?> Function(SqliteWriteContext tx, T obj) readBack;
  final DBExec<T> writer;
  final List<String> Function(T obj) uniqueColumn;

  static Map<Type, Map<String, dynamic>> runtimeTypeMapper = {
    CLEntity: {
      'table': 'Entity',
      'fromMap': CLEntity.fromMap,
      'toMap': (CLEntity obj) => obj.toMap(),
      'readBack': (SqliteWriteContext tx, CLEntity obj) async {
        final q = await DBResources.toDBQuery<CLEntity>(
          tx,
          'Entity',
          Shortcuts.mediaQuery(obj),
        );
        return q.get(tx);
      },
    },
  };

  static Future<DBQuery<T>> toDBQuery<T>(
    SqliteWriteContext tx,
    String tableName, [
    StoreQuery<T>? query,
  ]) async {
    final columnInfo = await tx.execute('PRAGMA table_info($tableName)');
    final validColumns = columnInfo.map((row) => row['name'] as String).toSet();

    // Step 2: Build WHERE clause
    final whereParts = <String>[];
    final params = <dynamic>[];

    if (query != null) {
      for (final query in query.map.entries) {
        final key = query.key;
        final value = query.value;
        if (validColumns.contains(key)) {
          switch (value) {
            case null:
              whereParts.add('$key IS NULL');
            case (final List<dynamic> e) when value.isNotEmpty:
              whereParts
                  .add('$key IN (${List.filled(e.length, '?').join(', ')})');
              params.addAll(e);
            case (final NotNullValues _):
              whereParts.add('$key IS NOT NULL');
            default:
              whereParts.add('$key IS ?');
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
    );
  }
}
