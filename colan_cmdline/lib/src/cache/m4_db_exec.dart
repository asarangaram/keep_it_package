import 'package:colan_cmdline/src/db_utils/db_command.dart';
import 'package:colan_cmdline/src/db_utils/db_command_batch.dart';
import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

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
    bool ignore = false,
  }) async {
    final map = toMap(obj);
    if (map == null) return null;

    await DBCommand.upsert(
      map,
      table: table,
      isPresent: (id) {
        throw UnimplementedError('isPresent not implemented');
      },
    ).execute(tx);

    final result = await readBack?.call(tx, obj);
    _infoLogger('Readback:  $result');
    return result;
  }

  Future<List<T?>> upsertAll(
    SqliteWriteContext tx,
    List<T> objList,
  ) async {
    final list =
        objList.map(toMap).where((e) => e != null).map((e) => e!).toList();

    DBBatchCommand.upsert(
      list,
      table: table,
      getPresentIdList: (ids) {
        throw UnimplementedError('isPresent not implemented');
      },
    );

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

  Future<void> deleteFromMap(
    SqliteWriteContext tx,
    Map<String, dynamic> identifierMap, {
    List<String>? identifier,
  }) async {
    await DBCommand.delete(
      identifierMap,
      table: table,
      identifiers: identifier,
    ).execute(tx);
  }
}

const _filePrefix = 'DB Write (internal): ';
bool _disableInfoLogger = false;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
