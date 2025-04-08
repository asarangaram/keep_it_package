import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'local_store.dart';

final storeProvider =
    FutureProvider.family<CLStore, String>((ref, storeIdentity) async {
  final stores = await ref.watch(storesProvider.future);

  if (stores.containsKey(storeIdentity)) {
    return stores[storeIdentity]!;
  } else {
    throw Exception('Store with identity $storeIdentity not found');
  }
});

final storesProvider = FutureProvider<Map<String, CLStore>>((ref) async {
  final localStore = await ref.watch(localStoreProvider.future);

  // add online store here..

  return {localStore.identity: CLStore(store: localStore)};
});
