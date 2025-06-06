import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../storage_service/providers/directories.dart';
import '../models/registerred_urls.dart';
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

class AvailableStoresNotifier extends AsyncNotifier<RegisteredURLs> {
  @override
  FutureOr<RegisteredURLs> build() {
    return RegisteredURLs();
  }

  StoreURL get activeStore => state.value!.activeStore;
  set activeStore(StoreURL storeURL) =>
      state = AsyncValue.data(state.value!.setActiveStore(storeURL));
}

final availableStoresProvider =
    AsyncNotifierProvider<AvailableStoresNotifier, RegisteredURLs>(
        AvailableStoresNotifier.new);
