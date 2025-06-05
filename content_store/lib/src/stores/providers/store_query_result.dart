import 'dart:async';

import 'package:content_store/src/stores/providers/stores.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'refresh_cache.dart';

class EntitiesNotifier
    extends FamilyAsyncNotifier<List<StoreEntity>, EntityQuery> {
  @override
  FutureOr<List<StoreEntity>> build(EntityQuery arg) async {
    final dbQuery = arg;
    final identity = dbQuery.storeIdentity;

    ref.watch(reloadProvider);
    if (identity != null) {
      final store = await ref.watch(storeProvider(identity).future);
      return store.getAll(dbQuery);
    } else {
      throw UnimplementedError();
    }
  }
}

final entitiesProvider = AsyncNotifierProviderFamily<EntitiesNotifier,
    List<StoreEntity>, EntityQuery>(EntitiesNotifier.new);
