import 'package:colan_widgets/colan_widgets.dart';
import 'package:collection/collection.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:sqlite_async/sqlite_async.dart';

@immutable
class DBQuery<T> {
  factory DBQuery({
    required String sql,
    required Set<String> triggerOnTables,
    required T? Function(
      Map<String, dynamic> map, {
      required AppSettings appSettings,
    }) fromMap,
    List<Object?>? parameters,
  }) {
    final (sql0, parameters0) = preprocessSqlAndParams(sql, parameters);
    return DBQuery._(
      sql: sql0,
      triggerOnTables: triggerOnTables,
      fromMap: fromMap,
      parameters: parameters0,
    );
  }
  const DBQuery._({
    required this.sql,
    required this.triggerOnTables,
    required this.fromMap,
    this.parameters,
  });

  final String sql;
  final Set<String> triggerOnTables;
  final List<Object?>? parameters;
  final T? Function(
    Map<String, dynamic> map, {
    required AppSettings appSettings,
  }) fromMap;

  DBQuery<T> copyWith({
    String? sql,
    Set<String>? triggerOnTables,
    List<Object?>? parameters,
    T Function(
      Map<String, dynamic> map, {
      required AppSettings appSettings,
    })? fromMap,
  }) {
    return DBQuery<T>(
      sql: sql ?? this.sql,
      triggerOnTables: triggerOnTables ?? this.triggerOnTables,
      parameters: parameters ?? this.parameters,
      fromMap: fromMap ?? this.fromMap,
    );
  }

  @override
  String toString() {
    return 'DBQuery(sql: $sql, triggerOnTables: $triggerOnTables, '
        'parameters: $parameters, fromMap: $fromMap)';
  }

  @override
  bool operator ==(covariant DBQuery<T> other) {
    final bool res;
    if (identical(this, other)) {
      res = true;
    } else {
      final collectionEquals = const DeepCollectionEquality().equals;

      res = other.sql == sql &&
          collectionEquals(other.triggerOnTables, triggerOnTables) &&
          collectionEquals(other.parameters, parameters) &&
          other.fromMap == fromMap;
    }

    return res;
  }

  /// Fix:
  /// The paramerters as a list causes different hash, that
  /// invokes frequent rebuild in top level.
  /// need to be carefull while comparing.
  ///
  @override
  int get hashCode {
    var hashCode = sql.hashCode ^ triggerOnTables.hashCode ^ fromMap.hashCode;
    if (parameters != null) {
      for (final p in parameters!) {
        hashCode ^= p.hashCode;
      }
    }
    return hashCode;
  }

  // Use this only to pick specific items, not cached.
  Future<List<T>> readMultiple(
    SqliteWriteContext tx, {
    required AppSettings appSettings,
    required bool validate,
  }) async {
    _infoLogger('cmd: $sql, $parameters');
    final objs = (await tx.getAll(sql, parameters ?? []))
        .map((m) => fromMap(m, appSettings: appSettings))
        .where((e) => e != null)
        .map((e) => e! as T)
        .toList();
    _infoLogger("read: ${objs.map((e) => e.toString()).join(', ')}");
    return objs;
  }

  Future<T?> read(
    SqliteWriteContext tx, {
    required AppSettings appSettings,
    required bool validate,
  }) async {
    _infoLogger('cmd: $sql, $parameters');
    final obj = (await tx.getAll(sql, parameters ?? []))
        .map((m) => fromMap(m, appSettings: appSettings))
        .firstOrNull;
    _infoLogger('read $obj');
    return obj;
  }

  static List<String> _extractContentInsideParentheses(String input) {
    final regex = RegExp(r'\(([^)]*)\)');
    final Match? match = regex.firstMatch(input);
    final matchedString = match?.group(1) ?? '';
    final res = matchedString.split(',').map((e) => e.trim()).toList();

    return res;
  }

  static (String, List<dynamic>?) preprocessSqlAndParams(
    String sql,
    List<Object?>? parameters,
  ) {
    if (parameters == null) {
      return (sql, parameters);
    }
    try {
      var paramIndex = 0;
      final processedParameters = <Object?>[];

      final processedSql = sql.replaceAllMapped(
        RegExp(r'\?|\(\?\)'),
        (match) {
          if (match.group(0) == '(?)') {
            final parameter = parameters[paramIndex]! as String;
            final splittedParams = _extractContentInsideParentheses(parameter);

            for (var i = 0; i < splittedParams.length; i++) {
              processedParameters.add(splittedParams[i]);
            }

            final processed = "(${splittedParams.map((e) => '?').join(', ')})";
            paramIndex++;
            return processed;
          } else {
            processedParameters.add(parameters[paramIndex]);
            paramIndex++;
            return match.group(0)!;
          }
        },
      );

      return (processedSql, processedParameters);
    } catch (e) {
      return (sql, parameters);
    }
  }
}

const _filePrefix = 'DB Read (internal): ';
bool _disableInfoLogger = true;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
