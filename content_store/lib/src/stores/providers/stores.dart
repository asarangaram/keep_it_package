import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import 'local_store.dart';

final storeProvider =
    FutureProvider.family<CLStore, EntityStore>((ref, store) async {
  return CLStore(
    store: store,
  );
});

final storesProvider = FutureProvider<Map<String, CLStore>>((ref) async {
  final localStore = await ref.watch(localStoreProvider.future);
  final store = await ref.watch(storeProvider(localStore).future);

  // add online store here..

  return {store.store.identity: store};
});
