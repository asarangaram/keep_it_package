import 'package:colan_widgets/colan_widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite_async/sqlite_async.dart';

@immutable
class DBExec<T> {
  const DBExec({
    required this.table,
    required this.toMap,
    required this.readBack,
  });
  final String table;
  final Map<String, dynamic> Function(
    T obj, {
    required AppSettings appSettings,
    required bool validate,
  }) toMap;
  final Future<T?> Function(
    SqliteWriteContext tx,
    T obj, {
    required AppSettings appSettings,
    required bool validate,
  })? readBack;

  DBExec<T> copyWith({
    String? table,
    Map<String, dynamic> Function(
      T obj, {
      required AppSettings appSettings,
      required bool validate,
    })? toMap,
    Future<T?> Function(
      SqliteWriteContext tx,
      T obj, {
      required AppSettings appSettings,
      required bool validate,
    })? readBack,
  }) {
    return DBExec<T>(
      table: table ?? this.table,
      toMap: toMap ?? this.toMap,
      readBack: readBack ?? this.readBack,
    );
  }

  @override
  bool operator ==(covariant DBExec<T> other) {
    if (identical(this, other)) return true;
    final mapEquals = const DeepCollectionEquality().equals;

    return other.table == table && mapEquals(other.toMap, toMap);
  }

  @override
  int get hashCode => table.hashCode ^ toMap.hashCode;

  @override
  String toString() => 'DBExec(table: $table, toMap: $toMap)';

  Future<T?> upsert(
    SqliteWriteContext tx,
    T obj, {
    required AppSettings appSettings,
    required bool validate,
    bool ignore = false,
  }) async {
    final cmd = _sql(
      obj,
      appSettings: appSettings,
      validate: validate,
      ignore: ignore,
    );
    _infoLogger('Exec:  $cmd');
    if (cmd.value.isNotEmpty) {
      await tx.execute(cmd.key, cmd.value);
    }
    final result = await readBack?.call(
      tx,
      obj,
      appSettings: appSettings,
      validate: validate,
    );
    _infoLogger('Readback:  $result');
    return result;
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
      _infoLogger('Exec:  $cmd');
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
        await readBack?.call(
          tx,
          obj,
          appSettings: appSettings,
          validate: validate,
        ),
      );
    }
    _infoLogger('Readback:  $result');
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
    _infoLogger('Readback:  $sql, $value');
    await tx.execute(sql, value);
  }

  MapEntry<String, List<String>> _sql(
    T obj, {
    required AppSettings appSettings,
    required bool validate,
    bool ignore = false,
  }) {
    final map = toMap(
      obj,
      appSettings: appSettings,
      validate: validate,
    );

    String? id;
    if (map.containsKey('id') && map['id'] != null) {
      id = map['id']!.toString();
    }
    final keys = map.keys.where((e) => e != 'id');
    final values = keys.map((e) => map[e].toString()).toList();
    final String sql;
    if (id != null) {
      sql = 'UPDATE '
          '$table SET ${keys.map((e) => '$e =?').join(', ')} '
          'WHERE id = ?';
      values.add(id);
    } else {
      sql =
          'INSERT ${ignore ? "OR IGNORE" : ""} INTO $table (${keys.join(', ')}) '
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

const _filePrefix = 'DB Write (internal): ';
bool _disableInfoLogger = true;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
