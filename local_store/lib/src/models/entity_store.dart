import 'package:meta/meta.dart';
import 'package:store/store.dart';

import '../implementations/sqlite_db/db_store.dart';
import '../implementations/sqlite_db/db_table_mixin.dart';
import '../implementations/sqlite_db/table_agent.dart';
import 'db_query.dart';

@immutable
class LocalSQLiteEntityStore extends EntityStore
    with SQLiteDBTableMixin<CLEntity> {
  LocalSQLiteEntityStore(this.agent);
  final SQLiteTableAgent<CLEntity> agent;

  @override
  Future<bool> delete(CLEntity item) async {
    try {
      await dbDelete(agent, item);
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<CLEntity?> get([StoreQuery<CLEntity>? query]) async {
    final dbQuery =
        DBQuery.fromStoreQuery(agent.table, agent.validColumns, query);
    return dbGet(agent, dbQuery);
  }

  @override
  Future<List<CLEntity>> getAll([StoreQuery<CLEntity>? query]) async {
    final dbQuery =
        DBQuery.fromStoreQuery(agent.table, agent.validColumns, query);
    return dbGetAll(agent, dbQuery);
  }

  @override
  Future<CLEntity?> upsert(
    CLEntity curr, {
    CLEntity? prev,
    String? mediaFile,
  }) async =>
      dbUpsert(agent, curr);

  static Future<EntityStore> create(DBModel db) async {
    const tableName = 'entity';
    final sqliteDB = db as SQLiteDB;
    final columnInfo = await db.db.execute('PRAGMA table_info($tableName)');
    final validColumns = columnInfo.map((row) => row['name'] as String).toSet();

    final agent = SQLiteTableAgent<CLEntity>(
      db: sqliteDB.db,
      table: 'Entity',
      fromMap: CLEntity.fromMap,
      toMap: (CLEntity obj) => obj.toMap(),
      dbQueryForItem: (CLEntity obj) async => DBQuery.fromStoreQuery(
        tableName,
        validColumns,
        Shortcuts.mediaQuery(obj),
      ),
      getUniqueColumns: (CLEntity obj) {
        return ['id', if (obj.isCollection) 'label' else 'md5'];
      },
      validColumns: validColumns,
    );

    return LocalSQLiteEntityStore(agent);
  }
}
