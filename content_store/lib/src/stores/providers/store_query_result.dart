import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'active_store_provider.dart';
import 'refresh_cache.dart';
import 'registerred_urls.dart';

class EntitiesNotifier
    extends FamilyAsyncNotifier<List<StoreEntity>, StoreQuery<CLEntity>>
    with CLLogger {
  @override
  String get logPrefix => 'EntitiesNotifier';
  @override
  FutureOr<List<StoreEntity>> build(StoreQuery<CLEntity> arg) async {
    try {
      final dbQuery = arg;

      ref.watch(reloadProvider);
      final store = await ref.watch(activeStoreProvider.future);
      if (store.store.isAlive) {
        try {
          return store.getAll(dbQuery);
        } catch (e) {
          /// FIXME : Implement here
          /// When failed, the issue could be that the server become inaccessible.
          /// Need to act here...
          ref.invalidate(registeredURLsProvider);
          return [];
        }
      } else {
        ref.invalidate(registeredURLsProvider);
        return [];
      }
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }
}

final entitiesProvider = AsyncNotifierProviderFamily<EntitiesNotifier,
    List<StoreEntity>, StoreQuery<CLEntity>>(EntitiesNotifier.new);
