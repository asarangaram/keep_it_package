import 'package:store/store.dart';

import '../models/entity_store.dart';
import 'sqlite_db/db_store.dart';

Future<DBModel> createSQLiteDBInstance(
  String fullPath, {
  required void Function() onReload,
}) async {
  return SQLiteDB.create(
    dbpath: fullPath,
    onReload: onReload,
  );
}

Future<EntityStore> createEntityStore(DBModel db) {
  return switch (db) {
    (final SQLiteDB db) => LocalSQLiteEntityStore.create(db),
    _ => throw Exception('Unsupported DB')
  };
}
