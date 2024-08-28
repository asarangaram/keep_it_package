import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'p2_db_manager.dart';

final dbReaderProvider =
    StreamProvider.family<List<dynamic>, StoreQuery<dynamic>>(
        (ref, dbQuery) async* {
  final controller = StreamController<List<dynamic>>();
  StreamSubscription<List<dynamic>>? subscription;

  ref.watch(storeProvider).when(
    data: (StoreManager storeManager) {
      subscription?.cancel(); // Cancel earlier subscription if any.
      subscription =
          storeManager.store.storeReaderStream<dynamic>(dbQuery).listen(
                controller.add,
                onDone: () => subscription?.cancel(),
              );
    },
    error: (e, st) {
      subscription?.cancel();
    },
    loading: () {
      // subscription?.cancel(); // can we continue
    },
  );
  ref.onDispose(() {
    subscription?.cancel();
    controller.close();
  });

  yield* controller.stream;
});
