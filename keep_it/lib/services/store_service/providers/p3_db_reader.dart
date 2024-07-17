import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'p2_db_manager.dart';

final dbReaderProvider =
    StreamProvider.family<List<dynamic>, StoreQuery<dynamic>>(
        (ref, dbQuery) async* {
  final dbManager = await ref.watch(storeProvider.future);
  // Handling 'IN ???'

  yield* dbManager.storeReaderStream<dynamic>(dbQuery);
});
