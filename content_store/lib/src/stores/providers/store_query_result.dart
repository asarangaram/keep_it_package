import 'dart:async';

import 'package:content_store/src/stores/providers/stores.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'refresh_cache.dart';

final entitiesProvider = StreamProvider.family<List<StoreEntity>, EntityQuery>(
    (ref, dbQuery) async* {
  final identity = dbQuery.storeIdentity;
  Future<List<StoreEntity>> Function() getentities;
  if (identity != 'local') {
    throw Exception('Unknown store!');
  }
  if (identity != null) {
    final store = await ref.watch(storeProvider(identity).future);

    getentities = () async {
      return store.getAll(dbQuery);
    };
  } else {
    final entityStores = await ref.watch(storesProvider.future);
    final stores = await Future.wait(
      entityStores.values
          .map((e) => ref.watch(storeProvider(e.store.identity).future))
          .toList(),
    );

    getentities = () async {
      return [
        for (final store in stores) ...await store.getAll(dbQuery),
      ];
    };
  }

  final controller = StreamController<List<StoreEntity>>();
  ref.listen(reloadProvider, (prev, curr) async {
    if (prev != curr) {
      final items = await getentities();
      controller.add(items);
    }
  });
  final items = await getentities();
  yield items;
  yield* controller.stream;
});
