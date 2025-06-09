import 'dart:async';

import 'package:content_store/src/stores/providers/network_scanner.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/registerred_urls.dart';

class RegisteredURLsNotifier extends AsyncNotifier<RegisteredURLs> {
  @override
  FutureOr<RegisteredURLs> build() {
    final scanner = ref.watch(networkScannerProvider);

    return RegisteredURLs(availableStores: [
      ...[
        defaultStore,
        StoreURL.fromString('local://QuotesCollection',
            identity: 'Quote Collection'),
        // StoreURL.fromString('http://192.168.0.220:5001')
      ],
      if (scanner.lanStatus && scanner.servers != null) ...scanner.servers!
    ]);
  }

  StoreURL get activeStore => state.value!.activeStoreURL;
  set activeStore(StoreURL storeURL) =>
      state = AsyncValue.data(state.value!.setActiveStore(storeURL));
}

final registeredURLsProvider =
    AsyncNotifierProvider<RegisteredURLsNotifier, RegisteredURLs>(
        RegisteredURLsNotifier.new);
