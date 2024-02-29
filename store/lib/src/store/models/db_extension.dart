import 'package:sqlite_async/sqlite3.dart';
import 'package:sqlite_async/sqlite_async.dart';

extension DBSqliteDatabase on SqliteDatabase {
  Stream<List<Row>> watchRows(
    String sql, {
    Set<String> triggerOnTables = const {},
    List<Object?> parameters = const [],
  }) async* {
    final resultSet = await getAll(sql, parameters);
    yield resultSet;
    final stream = watch(
      sql,
      parameters: parameters,
      triggerOnTables: triggerOnTables.toList(),
    );
    await for (final event in stream) {
      final rows = <Row>[];
      final iterator = event.iterator;
      while (iterator.moveNext()) {
        final row = iterator.current;
        rows.add(row);
      }
      yield rows;
    }
  }
}
