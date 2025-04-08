import 'package:store/store.dart';
import 'sqlite_db/db_store.dart';

Future<DBModel> createSQLiteDBInstance(String fullPath) async {
  return SQLiteDB.create(
    dbpath: fullPath,
  );
}
