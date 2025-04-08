import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'm2_db_migration.dart';

@immutable
class SQLiteDB extends DBModel {
  factory SQLiteDB({
    required SqliteDatabase db,
  }) {
    return SQLiteDB._(
      db: db,
    );
  }
  const SQLiteDB._({
    required this.db,
  });

  final SqliteDatabase db;

  static Future<SQLiteDB> create({
    required String dbpath,
  }) async {
    final db = SqliteDatabase(path: dbpath);
    await migrations.migrate(db);
    final dbManager = SQLiteDB(
      db: db,
    );

    return dbManager;
  }

  @override
  Future<void> dispose() async => db.close();
}
