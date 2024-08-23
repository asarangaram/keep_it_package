import 'dart:async';

import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'db_utils/db_command.dart';

@immutable
class DBExec<T> {
  const DBExec({
    required this.table,
    required this.toMap,
    required this.readBack,
  });
  final String table;
  final Map<String, dynamic>? Function(T obj) toMap;
  final Future<T?> Function(SqliteWriteContext tx, T obj)? readBack;

  Future<T?> upsert(
    SqliteWriteContext tx,
    T obj, {
    required List<String> uniqueColumn,
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
      ).execute(tx);
      result = await readBack?.call(tx, obj);
    } else {
      if (map == null) {
        throw Exception("couldn't not get map for the given object");
      }

      final bool insertStatus;

      insertStatus = await DBCommand.upsert(
        tx,
        map,
        table: table,
        getItemByColumnValue: (key, value) async {
          return (await tx
                  .getAll('SELECT * FROM $table WHERE $key = ?', [value]))
              .firstOrNull;
        },
        uniqueColumn: uniqueColumn,
      );

      if (!insertStatus) {
        throw Exception("couldn't not upsert");
      }

      result = await readBack?.call(tx, obj);
      if (result == null) {
        throw Exception('Upsert to $table failed');
      }
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
          (await upsert(tx, obj, uniqueColumn: uniqueColumn)) as T,
        );
      } catch (e) {
        /** */
      }
    }
    return updated;
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
