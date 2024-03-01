import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'm1_app_settings.dart';
import 'm3_db_queries.dart';
import 'm3_db_query.dart';

@immutable
class DBTable<T> {
  const DBTable({
    required this.table,
    required this.toMap,
    this.lableQuery,
  });
  final String table;
  final Map<String, dynamic> Function(
    T obj, {
    required AppSettings appSettings,
    required bool validate,
  }) toMap;
  final DBQueries? lableQuery;

  DBTable<T> copyWith({
    String? table,
    Map<String, dynamic> Function(
      T obj, {
      required AppSettings appSettings,
      required bool validate,
    })? toMap,
  }) {
    return DBTable<T>(
      table: table ?? this.table,
      toMap: toMap ?? this.toMap,
    );
  }

  @override
  bool operator ==(covariant DBTable<T> other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other.table == table && mapEquals(other.toMap, toMap);
  }

  @override
  int get hashCode => table.hashCode ^ toMap.hashCode;

  @override
  String toString() => 'DBExec(table: $table, toMap: $toMap)';

  Future<T?> read(
    SqliteWriteContext tx,
    T obj, {
    required AppSettings appSettings,
    required bool validate,
  }) async {
    final map = toMap(obj, appSettings: appSettings, validate: validate);
    if (map.containsKey('label') && lableQuery != null) {
      return (lableQuery! as DBQuery<T>)
          .copyWith(parameters: [map['label']]).read(
        tx,
        appSettings: appSettings,
        validate: validate,
      );
    }

    return null;
  }

  Future<T?> upsert(
    SqliteWriteContext tx,
    T obj, {
    required AppSettings appSettings,
    required bool validate,
  }) async {
    final cmd = _sql(
      obj,
      appSettings: appSettings,
      validate: validate,
    );
    if (cmd.value.isNotEmpty) {
      await tx.execute(cmd.key, cmd.value);
    }
    return read(
      tx,
      obj,
      appSettings: appSettings,
      validate: validate,
    );
  }

  Future<List<T?>> upsertAll(
    SqliteWriteContext tx,
    List<T> objList, {
    required AppSettings appSettings,
    required bool validate,
  }) async {
    for (final cmd in formatSQL(
      objList,
      appSettings: appSettings,
      validate: validate,
    ).entries) {
      if (cmd.value.isNotEmpty) {
        if (cmd.value.length == 1) {
          await tx.execute(cmd.key, cmd.value[0]);
        } else {
          await tx.executeBatch(cmd.key, cmd.value);
        }
      }
    }
    final result = <T?>[];
    for (final obj in objList) {
      result.add(
        await read(
          tx,
          obj,
          appSettings: appSettings,
          validate: validate,
        ),
      );
    }
    return result;
  }

  Future<void> delete(
    SqliteWriteContext tx,
    Map<String, String> identifierMap, {
    List<String>? identifier,
  }) async {
    final keys = identifierMap.keys;
    final value = keys.map((e) => identifierMap[e]).toList();

    final sql =
        'DELETE FROM $table WHERE ${keys.map((e) => '$e = ?').join(', ')}';

    await tx.execute(sql, value);
  }

  MapEntry<String, List<String>> _sql(
    T obj, {
    required AppSettings appSettings,
    required bool validate,
  }) {
    final map = toMap(
      obj,
      appSettings: appSettings,
      validate: validate,
    );

    String? id;
    if (map.containsKey('id')) {
      id = map['id']!.toString();
    }
    final keys = map.keys.where((e) => e != 'id' && map[e] != null);
    final values = keys.map((e) => map[e].toString()).toList();
    final String sql;
    if (id != null) {
      sql = 'UPDATE $table SET ${keys.map((e) => '$e =?').join(', ')} '
          'WHERE id = ?';
    } else {
      sql = 'INSERT INTO $table (${keys.join(', ')}) '
          'VALUES (${keys.map((e) => '?').join(', ')}) ';
    }
    return MapEntry(sql, values);
  }

  Map<String, List<List<String>>> formatSQL(
    List<T> objList, {
    required AppSettings appSettings,
    required bool validate,
  }) {
    final execCmdList = <String, List<List<String>>>{};

    for (final obj in objList) {
      final entry = _sql(obj, appSettings: appSettings, validate: validate);
      if (!execCmdList.containsKey(entry.key)) {
        execCmdList[entry.key] = [];
      }
      execCmdList[entry.key]!.add(entry.value);
    }
    return execCmdList;
  }
}
