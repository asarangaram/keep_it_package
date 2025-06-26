import 'dart:async';

import 'package:content_store/src/stores/providers/network_scanner.dart';
import 'package:content_store/src/stores/providers/store_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/registerred_urls.dart';

class RegisteredURLsNotifier extends AsyncNotifier<RegisteredURLs>
    with CLLogger {
  @override
  String get logPrefix => 'RegisteredURLsNotifier';
  final defaultStore = StoreURL.fromString('local://default',
      identity: null, label: 'Primary Collection');
  @override
  FutureOr<RegisteredURLs> build() {
    try {
      final scanner = ref.watch(networkScannerProvider);
      final servers = [
        defaultStore,
        StoreURL.fromString('local://QuotesCollection',
            identity: 'Quote Collection', label: 'Quote Collection'),
        // StoreURL.fromString('http://192.168.0.220:5001')

        if (scanner.lanStatus && scanner.servers != null) ...scanner.servers!
      ];

      final registeredURLs =
          RegisteredURLs(availableStores: servers, activeStoreIndex: 0);
      ref.listen(storeProvider(registeredURLs.activeStoreURL), (prev, next) {
        next.whenData((store) {
          if (!store.store.isAlive) {
            // assuming 0 is always available
            activeStore = registeredURLs.availableStores[0];
          }
        });
      });

      return registeredURLs;
    } catch (e) {
      log(e.toString());
      rethrow;
    }
  }

  StoreURL get activeStore => state.value!.activeStoreURL;
  set activeStore(StoreURL storeURL) =>
      state = AsyncValue.data(state.value!.setActiveStore(storeURL));
}

final registeredURLsProvider =
    AsyncNotifierProvider<RegisteredURLsNotifier, RegisteredURLs>(
        RegisteredURLsNotifier.new);
