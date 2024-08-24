import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'store.dart';

final dbReaderProvider =
    StreamProvider.family<List<dynamic>, StoreQuery<dynamic>>(
        (ref, dbQuery) async* {
  final dbManager = await ref.watch(storeProvider.future);
  // Handling 'IN ???'

  yield* dbManager.storeReaderStream<dynamic>(dbQuery);
});
