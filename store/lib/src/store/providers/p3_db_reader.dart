import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/m2_db_manager.dart';
import '../models/m3_db_query.dart';
import 'p2_db_manager.dart';

final dbReaderProvider = StreamProvider.family<List<dynamic>, DBQuery<dynamic>>(
    (ref, dbQuery) async* {
  final dbManager = await ref.watch(storeProvider.future) as DBManager;
  // Handling 'IN ???'

  yield* dbManager.storeReaderStream<dynamic>(dbQuery);
});
