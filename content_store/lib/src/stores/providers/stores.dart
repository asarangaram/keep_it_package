import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../storage_service/providers/directories.dart';
import '../models/available_stores.dart';
import 'local_store.dart';

class StoreNotifier extends AsyncNotifier<CLStore> {
  @override
  FutureOr<CLStore> build() async {
    final directories = await ref.watch(deviceDirectoriesProvider.future);
    final availableStores = await ref.watch(availableStoresProvider.future);
    final storeURL = availableStores.activeStore;

    final scheme = storeURL.scheme; // local or https

    final store = switch (scheme) {
      'local' => await ref.watch(localStoreProvider(storeURL).future),
      _ => throw Exception('Unexpected')
    };
    return CLStore(store: store, tempFilePath: directories.temp.pathString);
  }
}

final storeProvider =
    AsyncNotifierProvider<StoreNotifier, CLStore>(StoreNotifier.new);

/* final activeStoreURLProvider = StateProvider<String>((ref) {
  return 'local://default';
}); */

class AvailableStoresNotifier extends AsyncNotifier<AvailableStores> {
  @override
  FutureOr<AvailableStores> build() {
    return AvailableStores();
  }
}

final availableStoresProvider =
    AsyncNotifierProvider<AvailableStoresNotifier, AvailableStores>(
        AvailableStoresNotifier.new);
