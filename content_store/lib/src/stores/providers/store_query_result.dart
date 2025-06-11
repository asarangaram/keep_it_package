import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'active_store_provider.dart';
import 'refresh_cache.dart';

class EntitiesNotifier
    extends FamilyAsyncNotifier<List<StoreEntity>, StoreQuery<CLEntity>>
    with CLLogger {
  @override
  String get logPrefix => 'EntitiesNotifier';
  @override
  FutureOr<List<StoreEntity>> build(StoreQuery<CLEntity> arg) async {
    final dbQuery = arg;

    ref.watch(reloadProvider);
    final store = await ref.watch(activeStoreProvider.future);
    return store.getAll(dbQuery);
  }
}

final entitiesProvider = AsyncNotifierProviderFamily<EntitiesNotifier,
    List<StoreEntity>, StoreQuery<CLEntity>>(EntitiesNotifier.new);
