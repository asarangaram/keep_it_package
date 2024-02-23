import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../extensions/db_queries.dart';
import '../models/db_queries.dart';
import 'db_manager.dart';

final itemsByTagIdProvider =
    FutureProvider.family<List<CLMedia>, DBQueries>((ref, dbQuery) async {
  final databaseManager = await ref.watch(dbManagerProvider.future);
  final pathPrefix = (await getApplicationDocumentsDirectory()).path;
  return dbQuery.getByTagId(databaseManager.db, pathPrefix: pathPrefix);
});
