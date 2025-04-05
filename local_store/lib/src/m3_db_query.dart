import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'table_resources.dart';

@immutable
class DBQuery<T> {
  factory DBQuery({
    required String sql,
    Set<String> triggerOnTables = const {},
    List<Object?>? parameters,
  }) {
    return DBQuery._(
      sql: sql,
      triggerOnTables: triggerOnTables,
      parameters: parameters,
    );
  }
  factory DBQuery.map({
    required String sql,
    Set<String> triggerOnTables = const {},
    List<Object?>? parameters,
  }) {
    return DBQuery._(
      sql: sql,
      triggerOnTables: triggerOnTables,
      parameters: parameters,
    );
  }
  const DBQuery._({
    required this.sql,
    this.triggerOnTables = const {},
    this.parameters,
  });

  final String sql;
  final Set<String> triggerOnTables;
  final List<Object?>? parameters;

  DBQuery<T> copyWith({
    String? sql,
    Set<String>? triggerOnTables,
    List<Object?>? parameters,
  }) {
    return DBQuery._(
      sql: sql ?? this.sql,
      triggerOnTables: triggerOnTables ?? this.triggerOnTables,
      parameters: parameters ?? this.parameters,
    );
  }

  @override
  String toString() {
    return 'DBQuery(sql: $sql, triggerOnTables: $triggerOnTables, parameters: $parameters)';
  }

  @override
  bool operator ==(covariant DBQuery<T> other) {
    if (identical(this, other)) return true;
    final collectionEquals = const DeepCollectionEquality().equals;

    return other.sql == sql &&
        collectionEquals(other.triggerOnTables, triggerOnTables) &&
        collectionEquals(other.parameters, parameters);
  }

  /// Fix:
  /// The paramerters as a list causes different hash, that
  /// invokes frequent rebuild in top level.
  /// need to be carefull while comparing.
  ///
  @override
  int get hashCode {
    return sql.hashCode ^
        triggerOnTables.hashCode ^
        (parameters?.fold(0, (hashInit, next) => hashInit! ^ next.hashCode) ??
            parameters.hashCode);
  }

  static Map<String, dynamic> fixedMap(Map<String, dynamic> map) {
    final updatedMap = <String, dynamic>{};
    const removeValues = ['null'];
    for (final e in map.entries) {
      final value = switch (e) {
        (final MapEntry<String, dynamic> _)
            when removeValues.contains(e.value) =>
          null,
        _ => e.value
      };
      if (value != null) {
        updatedMap[e.key] = value;
      }
    }
    return updatedMap;
  }

  Future<List<T>> getAll(
    SqliteWriteContext tx,
  ) async {
    _infoLogger('cmd: $sql, $parameters');
    final resources = tableResources[T] as DBResources<T>;
    final fromMap = resources.fromMap;
    final fectched = await tx.getAll(sql, parameters ?? []);
    final objs = fectched
        .map((e) => (fromMap != null) ? fromMap(fixedMap(e)) : e as T)
        .where((e) => e != null)
        .map((e) => e! as T)
        .toList();
    _infoLogger("read: ${objs.map((e) => e.toString()).join(', ')}");
    return objs;
  }

  Future<T?> get(SqliteWriteContext tx) async {
    _infoLogger('cmd: $sql, $parameters');
    final resources = tableResources[T] as DBResources<T>;
    final fromMap = resources.fromMap;
    final obj = (await tx.getAll(sql, parameters ?? []))
        .map((e) => (fromMap != null) ? fromMap(fixedMap(e)) : e as T)
        .firstOrNull;
    _infoLogger('read $obj');
    return obj;
  }
}

const _filePrefix = 'DB Read (internal): ';
bool _disableInfoLogger = true;

void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
