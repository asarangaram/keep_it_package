import 'package:collection/collection.dart';
import 'package:meta/meta.dart';

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
}
