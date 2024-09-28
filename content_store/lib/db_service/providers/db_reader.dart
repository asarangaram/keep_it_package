import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'store_updater.dart';

final dbReaderProvider =
    StreamProvider.family<List<dynamic>, StoreQuery<dynamic>>(
        (ref, dbQuery) async* {
  final storeUpdater = await ref.watch(storeUpdaterProvider.future);
  // Handling 'IN ???'

  yield* storeUpdater.store.storeReaderStream<dynamic>(dbQuery);
});
