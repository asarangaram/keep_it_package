import '../../models/db_query.dart';
import 'table_agent.dart';

mixin SQLiteDBTableMixin<T> {
  Future<T?> dbGet(SQLiteTableAgent<T> agent, DBQuery<T> query) async {
    return agent.db.writeTransaction((tx) async {
      return agent.get(tx, query);
    });
  }

  Future<List<T>> dbGetAll(SQLiteTableAgent<T> agent, DBQuery<T> query) async {
    return agent.db.writeTransaction((tx) async {
      return agent.getAll(tx, query);
    });
  }

  Future<T?> dbUpsert(SQLiteTableAgent<T> agent, T item) {
    return agent.db.writeTransaction((tx) async {
      return agent.upsert(tx, item);
    });
  }

  Future<void> dbDelete(SQLiteTableAgent<T> agent, T item) {
    return agent.db.writeTransaction((tx) async {
      return agent.delete(tx, item);
    });
  }
}
