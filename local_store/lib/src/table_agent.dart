import 'dart:async';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'db_utils/db_command.dart';
import 'm3_db_query.dart';

@immutable
class TableAgent<T> {
  const TableAgent({
    required this.db,
    required this.table,
    required this.fromMap,
    required this.toMap,
    required this.getByItem,
    required this.getUniqueColumn,
    this.autoIncrementId = true,
  });

  final SqliteDatabase db;
  final String table;
  final T Function(Map<String, dynamic>)? fromMap;
  final Map<String, dynamic>? Function(T obj) toMap;
  final StoreQuery<T> Function(T obj) getByItem;
  final List<String> Function(T obj) getUniqueColumn;
  final bool autoIncrementId;

  Future<bool> updateFromMap(
    SqliteWriteContext tx,
    Map<String, dynamic> map,
  ) async {
    return DBCommand.update(map, table: table).execute(tx);
  }

  Future<T?> readBack(SqliteWriteContext tx, T obj) => get(tx, getByItem(obj));

  Future<T?> upsert(
    SqliteWriteContext tx,
    T obj, {
    bool ignore = false,
  }) async {
    final T? result;
    final map = toMap(obj);

    _infoLogger('upsert to $table: $obj');
    if (ignore) {
      if (map == null) return null;
      await DBCommand.insert(
        map,
        table: table,
        ignore: ignore,
        autoIncrementId: autoIncrementId,
      ).execute(tx);
      result = await readBack.call(tx, obj);
    } else {
      if (map == null) {
        throw Exception("couldn't not get map for the given object");
      }

      final bool insertStatus;

      insertStatus = await DBCommand.upsert(
        tx,
        map,
        autoIncrementId: autoIncrementId,
        table: table,
        getItemByColumnValue: (key, value) async {
          return (await tx
                  .getAll('SELECT * FROM $table WHERE $key = ?', [value]))
              .firstOrNull;
        },
        uniqueColumn: getUniqueColumn(obj),
      );

      if (!insertStatus) {
        throw Exception("couldn't not upsert");
      }

      result = await readBack.call(tx, obj);
    }
    _infoLogger('upsertNote: Done :  $result');
    return result;
  }

  Future<void> delete(
    SqliteWriteContext tx,
    T obj, {
    List<String>? identifier,
  }) async {
    final map = toMap(obj);
    if (map == null) return;
    await DBCommand.delete(
      map,
      table: table,
      identifiers: identifier,
    ).execute(tx);
  }

  Future<List<T>> upsertAll(
    SqliteWriteContext tx,
    List<T> objs, {
    required List<String> uniqueColumn,
  }) async {
    final updated = <T>[];
    for (final obj in objs) {
      try {
        updated.add(
          (await upsert(tx, obj)) as T,
        );
      } catch (e) {
        /** */
      }
    }
    return updated;
  }

  static Map<String, dynamic> fixedMap(Map<String, dynamic> map) {
    final updatedMap = <String, dynamic>{};
    const removeValues = ['null'];
    for (final e in map.entries) {
      final value = switch (e) {
        (final MapEntry<String, dynamic> _)
            when removeValues.contains(e.value) =>
          null,
        _ => e.value
      };
      if (value != null) {
        updatedMap[e.key] = value;
      }
    }
    return updatedMap;
  }

  Future<List<T>> getAll(SqliteWriteContext tx, [StoreQuery<T>? query]) async {
    final q = await toDBQuery(tx, query);
    final sql = q.sql;
    final parameters = q.parameters;

    _infoLogger('cmd: $sql, $parameters');

    final fectched = await tx.getAll(sql, parameters ?? []);
    final objs = fectched
        .map((e) => (fromMap != null) ? fromMap!(fixedMap(e)) : e as T)
        .where((e) => e != null)
        .map((e) => e! as T)
        .toList();
    _infoLogger("read: ${objs.map((e) => e.toString()).join(', ')}");
    return objs;
  }

  Future<T?> get(SqliteWriteContext tx, [StoreQuery<T>? query]) async {
    final q = await toDBQuery(tx, query);
    final sql = q.sql;
    final parameters = q.parameters;

    _infoLogger('cmd: $sql, $parameters');

    final obj = (await tx.getAll(sql, parameters ?? []))
        .map((e) => (fromMap != null) ? fromMap!(fixedMap(e)) : e as T)
        .firstOrNull;
    _infoLogger('read $obj');
    return obj;
  }

  Future<DBQuery<T>> toDBQuery(
    SqliteWriteContext tx, [
    StoreQuery<T>? query,
  ]) async {
    final columnInfo = await tx.execute('PRAGMA table_info($table)');
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
    final sql = 'SELECT * FROM $table $whereClause';

    return DBQuery<T>.map(
      sql: sql,
      parameters: params,
    );
  }
}

const _filePrefix = 'DB Write (internal): ';
bool _disableInfoLogger = true;

String? prefixedMsg(String msg) {
  if (!_disableInfoLogger) {
    return '$_filePrefix$msg';
  }
  return null;
}

// Use prefixedMsg to log!
void _infoLogger(msg) {}
