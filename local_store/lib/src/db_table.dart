import 'package:store/store.dart';

import 'table_agent.dart';

mixin DBTable<T> {
  Future<T?> get(TableAgent<T> agent, [StoreQuery<T>? query]) async {
    return agent.db.writeTransaction((tx) async {
      return agent.get(tx, query);
    });
  }

  Future<List<T>> getAll(TableAgent<T> agent, [StoreQuery<T>? query]) async {
    return agent.db.writeTransaction((tx) async {
      return agent.getAll(tx, query);
    });
  }

  Future<T?> upsert(TableAgent<T> agent, T item) {
    return agent.db.writeTransaction((tx) async {
      return agent.upsert(tx, item);
    });
  }

  Future<void> delete(TableAgent<T> agent, T item) {
    return agent.db.writeTransaction((tx) async {
      return agent.delete(tx, item);
    });
  }
}
