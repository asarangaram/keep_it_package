import 'package:meta/meta.dart';

import 'db_exception.dart';
import 'db_extension_on_map.dart';

@immutable
class DBExecCommand {
  const DBExecCommand(
    this.sql,
    this.parameters,
  );
  factory DBExecCommand.insertFromMap(
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

    return DBExecCommand(sql, parameters);
  }

  factory DBExecCommand.updateFromMap(
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
    return DBExecCommand(sql, parameters);
  }

  factory DBExecCommand.deleteFromMap(
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
      sql = 'DELETE FROM $table '
          'WHERE ${map.keys.map((e) => '$e = ?').join(' AND ')}';
      parameters = identifiers;
    }
    return DBExecCommand(sql, parameters);
  }
  final String sql;
  final List<Object?> parameters;
}
