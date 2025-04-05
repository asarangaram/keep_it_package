import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/store.dart';

import 'm2_db_migration.dart';
import 'table_resources.dart';

class DBTable<T> {
  const DBTable(this.tx);
  final SqliteWriteContext tx;

  Future<T?> get([StoreQuery<T>? query]) async {
    final tableName = (tableResources[T] as DBResources<T>).table;
    final q = await DBResources.toDBQuery<T>(tx, tableName, query);
    return q.get(tx);
  }

  Future<List<T>> getAll([StoreQuery<T>? query]) async {
    final tableName = (tableResources[T] as DBResources<T>).table;
    final q = await DBResources.toDBQuery<T>(tx, tableName, query);

    return q.getAll(tx);
  }

  Future<T?> upsert(T item) {
    final resources = tableResources[T] as DBResources<T>;
    resources.writer
        .upsert(tx, item, uniqueColumn: resources.uniqueColumn(item));
    throw UnimplementedError();
  }

  Future<void> delete(T item) {
    final resources = tableResources[T] as DBResources<T>;
    resources.writer.delete(tx, item);

    throw UnimplementedError();
  }
}

class DBStore extends Store {
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

  @override
  Future<T?> get<T>([StoreQuery<T>? query]) {
    return db.writeTransaction((tx) async {
      return DBTable<T>(tx).get(query);
    });
  }

  @override
  Future<List<T>> getAll<T>([StoreQuery<T>? query]) {
    return db.writeTransaction((tx) async {
      return DBTable<T>(tx).getAll(query);
    });
  }

  @override
  Future<T?> upsert<T>(T item) {
    return db.writeTransaction((tx) async {
      return DBTable<T>(tx).upsert(item);
    });
  }

  @override
  Future<void> delete<T>(T item) {
    return db.writeTransaction((tx) async {
      return DBTable<T>(tx).delete(item);
    });
  }

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
