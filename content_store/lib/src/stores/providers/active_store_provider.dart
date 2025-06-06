import 'dart:async';

import 'package:content_store/src/stores/providers/registerred_urls.dart';
import 'package:content_store/src/stores/providers/store_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

class ActiveStoreNotifier extends AsyncNotifier<CLStore> {
  @override
  FutureOr<CLStore> build() async {
    final registerredURLs = await ref.watch(registeredURLsProvider.future);
    final storeURL = registerredURLs.activeStoreURL;

    final activeStore = ref.watch(storeProvider(storeURL).future);
    return activeStore;
  }
}

final activeStoreProvider = AsyncNotifierProvider<ActiveStoreNotifier, CLStore>(
    ActiveStoreNotifier.new);
