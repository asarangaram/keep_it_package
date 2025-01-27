import 'package:collection/collection.dart';
import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

@immutable
class DBQuery<T> extends StoreQuery<T> {
  factory DBQuery({
    required String sql,
    required Set<String> triggerOnTables,
    String dbPath = 'Not specified',
    List<Object?>? parameters,
  }) {
    final (sql0, parameters0) = preprocessSqlAndParams(sql, parameters);
    return DBQuery._(
      sql: sql0,
      triggerOnTables: triggerOnTables,
      fromMap: null,
      parameters: parameters0,
      dbPath: dbPath,
    );
  }
  factory DBQuery.map({
    required String sql,
    required Set<String> triggerOnTables,
    required T? Function(
      Map<String, dynamic> map,
    ) fromMap,
    String dbPath = 'Not specified',
    List<Object?>? parameters,
  }) {
    final (sql0, parameters0) = preprocessSqlAndParams(sql, parameters);
    return DBQuery._(
      sql: sql0,
      triggerOnTables: triggerOnTables,
      fromMap: fromMap,
      parameters: parameters0,
      dbPath: dbPath,
    );
  }
  const DBQuery._({
    required this.sql,
    required this.triggerOnTables,
    required this.fromMap,
    required this.dbPath,
    this.parameters,
  });

  final String sql;
  final Set<String> triggerOnTables;
  final List<Object?>? parameters;
  final T? Function(Map<String, dynamic> map)? fromMap;
  final String dbPath;

  DBQuery<T> copyWith({
    String? sql,
    Set<String>? triggerOnTables,
    List<Object?>? parameters,
    T? Function(Map<String, dynamic> map)? fromMap,
    String? dbPath,
  }) {
    return DBQuery._(
      sql: sql ?? this.sql,
      triggerOnTables: triggerOnTables ?? this.triggerOnTables,
      parameters: parameters ?? this.parameters,
      fromMap: fromMap ?? this.fromMap,
      dbPath: dbPath ?? this.dbPath,
    );
  }

  @override
  String toString() {
    return 'DBQuery(sql: $sql, triggerOnTables: $triggerOnTables, parameters: $parameters, fromMap: $fromMap, dbPath: $dbPath)';
  }

  @override
  bool operator ==(covariant DBQuery<T> other) {
    if (identical(this, other)) return true;
    final collectionEquals = const DeepCollectionEquality().equals;

    return other.sql == sql &&
        collectionEquals(other.triggerOnTables, triggerOnTables) &&
        collectionEquals(other.parameters, parameters) &&
        other.fromMap == fromMap &&
        other.dbPath == dbPath;
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
            parameters.hashCode) ^
        fromMap.hashCode ^
        dbPath.hashCode;
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

  // Use this only to pick specific items, not cached.
  Future<List<T>> readMultiple(
    SqliteWriteContext tx,
  ) async {
    _infoLogger('cmd: $sql, $parameters');
    final fectched = await tx.getAll(sql, parameters ?? []);
    final objs = fectched
        .map((e) => (fromMap != null) ? fromMap!(fixedMap(e)) : e as T)
        .where((e) => e != null)
        .map((e) => e! as T)
        .toList();
    _infoLogger("read: ${objs.map((e) => e.toString()).join(', ')}");
    return objs;
  }

  Future<T?> read(SqliteWriteContext tx) async {
    _infoLogger('cmd: $sql, $parameters');
    final obj = (await tx.getAll(sql, parameters ?? []))
        .map((e) => (fromMap != null) ? fromMap!(fixedMap(e)) : e as T)
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

  DBQuery<T> insertParameters(List<Object?> parameters) {
    final (sql0, parameters0) = DBQuery.preprocessSqlAndParams(sql, parameters);
    return copyWith(sql: sql0, parameters: parameters0);
  }
}

const _filePrefix = 'DB Read (internal): ';
bool _disableInfoLogger = true;

void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i('$_filePrefix$msg');
  }
}
