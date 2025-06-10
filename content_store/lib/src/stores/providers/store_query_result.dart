import 'dart:async';

import 'package:content_store/src/stores/providers/active_store_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'refresh_cache.dart';

class EntitiesNotifier
    extends FamilyAsyncNotifier<List<StoreEntity>, StoreQuery<CLEntity>> {
  @override
  FutureOr<List<StoreEntity>> build(StoreQuery<CLEntity> arg) async {
    final dbQuery = arg;

    ref.watch(reloadProvider);
    final store = await ref.watch(activeStoreProvider.future);
    try {
      return store.getAll(dbQuery);
    } catch (e) {
      /// FIXME : Implement here
      /// When failed, the issue could be that the server become inaccessible.
      /// Need to act here...

      print('getAll failed');
      return [];
    }
  }
}

final entitiesProvider = AsyncNotifierProviderFamily<EntitiesNotifier,
    List<StoreEntity>, StoreQuery<CLEntity>>(EntitiesNotifier.new);
