import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'p2_db_manager.dart';

final dbReaderProvider =
    StreamProvider.family<List<dynamic>, StoreQuery<dynamic>>(
        (ref, dbQuery) async* {
  final controller = StreamController<List<dynamic>>();
  StreamSubscription<List<dynamic>>? subscription;
  final storeManager = await ref.watch(storeProvider.future);

  subscription = storeManager.store.storeReaderStream<dynamic>(dbQuery).listen(
        controller.add,
        onDone: () => subscription?.cancel(),
      );

  ref.onDispose(() {
    subscription?.cancel();
    controller.close();
  });

  yield* controller.stream;
});
