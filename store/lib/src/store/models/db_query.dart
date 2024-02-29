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
  final T Function(Map<String, dynamic> map, {String? pathPrefix}) fromMap;

  DBQuery<T> copyWith({
    String? sql,
    Set<String>? triggerOnTables,
    List<Object?>? parameters,
    T Function(Map<String, dynamic> map, {String? pathPrefix})? fromMap,
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
    if (identical(this, other)) return true;
    final collectionEquals = const DeepCollectionEquality().equals;

    return other.sql == sql &&
        collectionEquals(other.triggerOnTables, triggerOnTables) &&
        collectionEquals(other.parameters, parameters) &&
        collectionEquals(other.fromMap, fromMap);
  }

  @override
  int get hashCode {
    return sql.hashCode ^
        triggerOnTables.hashCode ^
        parameters.hashCode ^
        fromMap.hashCode;
  }

  // Use this only to pick specific items, not cached.
  Future<List<T>> readMultiple(SqliteDatabase db) async {
    return (await db.getAll(sql, parameters ?? [])).map(fromMap).toList();
  }

  Future<T?> read(SqliteDatabase db) async {
    return (await db.getAll(sql, parameters ?? [])).map(fromMap).firstOrNull;
  }
}
