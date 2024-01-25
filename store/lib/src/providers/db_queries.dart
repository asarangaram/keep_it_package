import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/db_queries.dart';
import '../models/db_queries.dart';
import '../models/item.dart';
import 'db_manager.dart';

final itemsByCollectionIdProvider =
    FutureProvider.family<List<ItemInDB>, DBQueries>((ref, dbQuery) async {
  final databaseManager = await ref.watch(dbManagerProvider.future);
  return dbQuery.getByCollectionID(databaseManager.db);
});
