import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'db_utils/db_command.dart';
import 'db_utils/db_command_batch.dart';

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

  DBExec<T> copyWith({
    String? table,
    Map<String, dynamic>? Function(T obj)? toMap,
    Future<T?> Function(SqliteWriteContext tx, T obj)? readBack,
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

    return other.table == table &&
        mapEquals(other.toMap, toMap) &&
        other.readBack == readBack;
  }

  @override
  int get hashCode => table.hashCode ^ toMap.hashCode ^ readBack.hashCode;

  @override
  String toString() =>
      'DBExec(table: $table, toMap: $toMap, readBack: $readBack)';

  Future<T?> upsert(
    SqliteWriteContext tx,
    T obj, {
    required List<String> uniqueColumn,
    bool ignore = false,
  }) async {
    final map = toMap(obj);
    if (map == null) return null;

    await DBCommand.upsert(
      tx,
      map,
      table: table,
      getItemByColumnValue: (key, value) async {
        return (await tx.getAll('SELECT * FROM $table WHERE $key = ?', [value]))
            .firstOrNull;
      },
      uniqueColumn: uniqueColumn,
    );

    final result = await readBack?.call(tx, obj);
    _infoLogger('Readback:  $result');
    return result;
  }

  Future<T?> insert(
    SqliteWriteContext tx,
    T obj, {
    bool ignore = false,
  }) async {
    final map = toMap(obj);
    if (map == null) return null;

    await DBCommand.insert(
      map,
      table: table,
    ).execute(tx);

    final result = await readBack?.call(tx, obj);
    _infoLogger('Readback:  $result');
    return result;
  }

  Future<T?> update(
    SqliteWriteContext tx,
    T obj, {
    bool ignore = false,
  }) async {
    final map = toMap(obj);
    if (map == null) return null;

    await DBCommand.update(
      map,
      table: table,
    ).execute(tx);

    final result = await readBack?.call(tx, obj);
    _infoLogger('Readback:  $result');
    return result;
  }

  Future<List<T?>> upsertAll(
    SqliteWriteContext tx,
    List<T> objList, {
    required Future<List<int>> Function(List<int>) getPresentIdList,
  }) async {
    final list =
        objList.map(toMap).where((e) => e != null).map((e) => e!).toList();

    await (await DBBatchCommand.upsertAsync(
      list,
      table: table,
      getPresentIdList: getPresentIdList,
    ))
        .execute(tx);

    final result = <T?>[];
    for (final obj in objList) {
      result.add(
        await readBack?.call(tx, obj),
      );
    }
    _infoLogger('Readback:  $result');
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
}

const _filePrefix = 'DB Write (internal): ';
bool _disableInfoLogger = true;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
