import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'db_exception.dart';
import 'db_extension_on_map.dart';

@immutable
class DBCommand {
  const DBCommand(
    this.sql,
    this.parameters,
  );

  factory DBCommand.upsert(
    Map<String, dynamic> map, {
    required String table,
    required bool Function(int id) isPresent,
    bool autoIncrementId = true,
    bool ignore = false,
  }) {
    final bool update;
    update = map.hasID && isPresent(map.id!);

    if (update) {
      return DBCommand.update(
        map,
        table: table,
      );
    } else {
      return DBCommand.insert(
        map,
        table: table,
        autoIncrementId: autoIncrementId,
        ignore: ignore,
      );
    }
  }
  factory DBCommand.insert(
    Map<String, dynamic> map, {
    required String table,
    bool autoIncrementId = true,
    bool ignore = false,
  }) {
    if (map.hasID && autoIncrementId) {
      throw const DBException(DBErrorCode.autoIncrementIdViolationException);
    }

    final sql = 'INSERT ${ignore ? "OR IGNORE" : ""} '
        'INTO $table (${map.keys.join(', ')}) '
        'VALUES (${map.keys.map((e) => '?').join(', ')}) ';
    final parameters = map.values.map((e) => e as Object?).toList();

    return DBCommand(sql, [parameters]);
  }

  factory DBCommand.update(
    Map<String, dynamic> map, {
    required String table,
  }) {
    if (!map.hasID) {
      throw Exception(DBErrorCode.updateWithoutIdException);
    }

    final map1 = map.removeId();

    final sql = 'UPDATE '
        '$table SET ${map1.keys.map((e) => '$e =?').join(', ')} '
        'WHERE id = ? ';

    final parameters = [
      ...map1.values.map((e) => e as Object?),
      map.id,
    ];
    return DBCommand(sql, [parameters]);
  }

  factory DBCommand.delete(
    Map<String, dynamic> map, {
    required String table,
    List<String>? identifiers,
  }) {
    if (!map.hasID) {
      throw Exception(DBErrorCode.deleteWithoutIdException);
    }

    final String sql;
    final List<Object?> parameters;
    if (identifiers == null) {
      sql = 'DELETE FROM $table WHERE id = ?';
      parameters = [map.id];
    } else {
      final keys = map.keys.where((e) => identifiers.contains(e));
      final map1 = {for (final e in keys) e: map[e]};
      sql = 'DELETE FROM $table '
          'WHERE ${map1.keys.map((e) => '$e = ?').join(' AND ')}';
      parameters = map1.values.toList();
    }
    return DBCommand(sql, [parameters]);
  }
  final String sql;
  final List<List<Object?>> parameters;

  DBCommand copyWith({
    String? sql,
    List<List<Object?>>? parameters,
  }) {
    return DBCommand(
      sql ?? this.sql,
      parameters ?? this.parameters,
    );
  }

  @override
  String toString() => 'DBExecCommand(sql: $sql, parameters: $parameters)';

  @override
  bool operator ==(covariant DBCommand other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.sql == sql && listEquals(other.parameters, parameters);
  }

  @override
  int get hashCode => sql.hashCode ^ parameters.hashCode;

  DBCommand mergeParameters(DBCommand other) =>
      copyWith(parameters: [parameters, other.parameters]);

  DBCommand merge(DBCommand other) {
    if (other.sql == sql) {
      return mergeParameters(other);
    } else {
      throw const DBException(DBErrorCode.mergeFailedException);
    }
  }

  Future<bool> execute(SqliteWriteContext tx) async {
    if (parameters.isEmpty) {
      return false;
    }
    try {
      if (parameters.length == 1) {
        await tx.execute(sql, parameters[0]);
      } else {
        await tx.executeBatch(sql, parameters);
      }
      return true;
    } catch (e) {
      throw const DBException(DBErrorCode.executionFailed);
    }
  }
}
