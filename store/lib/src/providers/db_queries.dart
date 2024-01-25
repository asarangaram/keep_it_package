import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../extensions/db_queries.dart';
import '../models/db_queries.dart';
import '../models/item.dart';
import 'db_manager.dart';

final itemsByTagIdProvider =
    FutureProvider.family<List<ItemInDB>, DBQueries>((ref, dbQuery) async {
  final databaseManager = await ref.watch(dbManagerProvider.future);
  return dbQuery.getByTagID(databaseManager.db);
});
