// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'm1_app_settings.dart';

@immutable
class DBExec<T> {
  const DBExec({
    required this.sql,
     this.parameters,
    this.preprocess,
  });
  final String sql;
  final List<List<Object?>>? parameters;

  final Map<String, dynamic> Function(
    Map<String, dynamic> map, {
    required AppSettings appSettings,
    bool validate,
  })? preprocess;

  DBExec<T> copyWith({
    String? sql,
    List<List<Object?>>? parameters,
  }) {
    return DBExec<T>(
      sql: sql ?? this.sql,
      parameters: parameters ?? this.parameters,
    );
  }

  @override
  bool operator ==(covariant DBExec<T> other) {
    if (identical(this, other)) return true;
    final listEquals = const DeepCollectionEquality().equals;

    return other.sql == sql && listEquals(other.parameters, parameters);
  }

  @override
  int get hashCode => sql.hashCode ^ parameters.hashCode;

  @override
  String toString() => 'DBExec(sql: $sql, parameters: $parameters)';

  Future<void> executeBatch(SqliteWriteContext tx) async {
    await tx.executeBatch(sql, parameters?? []);
  }

  Future<void> exec(SqliteWriteContext tx) async {
    await tx.execute(sql, parameters?[0] ?? []);
  }
}
