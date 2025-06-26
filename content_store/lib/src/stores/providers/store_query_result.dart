import 'dart:async';

import 'package:cl_entity_viewers/cl_entity_viewers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'active_store_provider.dart';
import 'refresh_cache.dart';

class EntitiesNotifier
    extends FamilyAsyncNotifier<ViewerEntities, StoreQuery<CLEntity>>
    with CLLogger {
  @override
  String get logPrefix => 'EntitiesNotifier';
  @override
  FutureOr<ViewerEntities> build(StoreQuery<CLEntity> arg) async {
    final dbQuery = arg;

    ref.watch(reloadProvider);
    final store = await ref.watch(activeStoreProvider.future);
    return store.getAll(dbQuery);
  }
}

final entitiesProvider = AsyncNotifierProviderFamily<EntitiesNotifier,
    ViewerEntities, StoreQuery<CLEntity>>(EntitiesNotifier.new);
