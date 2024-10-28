import 'dart:async';
import 'dart:developer';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'store_updater.dart';

final dbReaderProvider =
    StreamProvider.family<List<dynamic>, StoreQuery<dynamic>>(
        (ref, dbQuery) async* {
  final storeUpdater = await ref.watch(storeUpdaterProvider.future);

  final controller = StreamController<List<dynamic>>();
  ref.listen(refreshReaderProvider, (prev, curr) async {
    if (prev != curr) {
      log(
        'Query triggered $dbQuery',
        name: 'dbReaderProvider',
        time: DateTime.now(),
      );
      controller.add(await storeUpdater.store.reader.readMultiple(dbQuery));
    }
  });

  // Handling 'IN ???'
  yield await storeUpdater.store.reader.readMultiple(dbQuery);
  yield* controller.stream;
});

final refreshReaderProvider = StateProvider<String>((ref) {
  ref.listenSelf((prev, curr) {
    log(
      'Trigger Refresh at $curr',
      name: 'refreshReaderProvider',
      time: DateTime.now(),
    );
  });

  return DateTime.now().toIso8601String();
});
