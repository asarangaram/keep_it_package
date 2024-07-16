import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/src/store/extensions/ext_sqlite_database.dart';

import '../models/m2_db_manager.dart';
import '../models/m3_db_query.dart';
import 'p2_db_manager.dart';

final dbReaderProvider = StreamProvider.family<List<dynamic>, DBQuery<dynamic>>(
    (ref, dbQuery) async* {
  final dbManager = await ref.watch(storeProvider.future) as DBManager;
  // Handling 'IN ???'

  final sub = dbManager.db
      .watchRows(
        dbQuery.sql,
        triggerOnTables: dbQuery.triggerOnTables,
        parameters: dbQuery.parameters ?? [],
      )
      .map(
        (rows) => rows
            .map((e) => dbQuery.fromMap(DBQuery.fixedMap(e)))
            .where((e) => e != null)
            .toList(),
      );
  await for (final res in sub) {
    yield res;
  }
});
