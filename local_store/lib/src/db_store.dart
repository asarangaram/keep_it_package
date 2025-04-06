import 'package:meta/meta.dart';
import 'package:sqlite_async/sqlite_async.dart';

import 'm2_db_migration.dart';

@immutable
abstract class DBStoreBase {
  const DBStoreBase();

  Future<void> reloadStore();
  Future<void> dispose();
}

@immutable
class DBStore extends DBStoreBase {
  factory DBStore({
    required SqliteDatabase db,
    required void Function() onReload,
  }) {
    return DBStore._(
      db: db,
      onReload: onReload,
    );
  }
  const DBStore._({
    required this.db,
    required this.onReload,
  });

  final SqliteDatabase db;
  final void Function() onReload;

  static Future<DBStore> createInstances({
    required String dbpath,
    required void Function() onReload,
  }) async {
    final db = SqliteDatabase(path: dbpath);
    await migrations.migrate(db);
    final dbManager = DBStore(
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
