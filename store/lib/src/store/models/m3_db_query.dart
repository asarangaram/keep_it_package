import 'package:colan_widgets/colan_widgets.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sqlite_async/sqlite_async.dart';

@immutable
class DBQuery<T> {
  const DBQuery({
    required this.sql,
    required this.triggerOnTables,
    required this.fromMap,
    this.parameters,
  });

  final String sql;
  final Set<String> triggerOnTables;
  final List<Object?>? parameters;
  final T Function(
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
}

const _filePrefix = 'DB Read (internal): ';
bool _disableInfoLogger = true;
// ignore: unused_element
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
