import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'm2_db_migration.dart';

@immutable
class SQLiteDB extends DBModel {
  factory SQLiteDB({
    required SqliteDatabase db,
    required void Function() onReload,
  }) {
    return SQLiteDB._(
      db: db,
      onReload: onReload,
    );
  }
  const SQLiteDB._({
    required this.db,
    required this.onReload,
  });

  final SqliteDatabase db;
  final void Function() onReload;

  static Future<SQLiteDB> create({
    required String dbpath,
    required void Function() onReload,
  }) async {
    final db = SqliteDatabase(path: dbpath);
    await migrations.migrate(db);
    final dbManager = SQLiteDB(
      db: db,
      onReload: onReload,
    );

    return dbManager;
  }

  @override
  Future<void> dispose() async => db.close();

  @override
  Future<void> reloadStore() async => onReload();
}
