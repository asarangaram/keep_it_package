import 'dart:async';

import 'package:content_store/src/stores/providers/stores.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../refresh_cache.dart';

final entitiesProvider =
    StreamProvider.family<List<CLEntity>, EntityQuery>((ref, dbQuery) async* {
  final stores = await ref.watch(storesProvider.future);
  Future<List<CLEntity>> getentities() async {
    return [
      for (final store in stores.values) ...(await store.getAll(dbQuery)),
    ];
  }

  final controller = StreamController<List<CLEntity>>();
  ref.listen(refreshReaderProvider, (prev, curr) async {
    if (prev != curr) {
      controller.add(await getentities());
    }
  });

  yield await getentities();
  yield* controller.stream;
});
