import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sqlite_async/sqlite_async.dart';

import '../models/m1_app_settings.dart';

@immutable
class DBReader<T> {
  const DBReader({
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
    required bool validate,
  }) fromMap;

  DBReader<T> copyWith({
    String? sql,
    Set<String>? triggerOnTables,
    List<Object?>? parameters,
    T Function(
      Map<String, dynamic> map, {
      required AppSettings appSettings,
      required bool validate,
    })? fromMap,
  }) {
    return DBReader<T>(
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
  bool operator ==(covariant DBReader<T> other) {
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
  Future<List<T>> readMultiple(
    SqliteDatabase db, {
    required AppSettings appSettings,
    required bool validate,
  }) async {
    return (await db.getAll(sql, parameters ?? []))
        .map((m) => fromMap(m, appSettings: appSettings, validate: validate))
        .toList();
  }

  Future<T?> read(
    SqliteWriteContext tx, {
    required AppSettings appSettings,
    required bool validate,
  }) async {
    return (await tx.getAll(sql, parameters ?? []))
        .map((m) => fromMap(m, appSettings: appSettings, validate: validate))
        .firstOrNull;
  }
}
