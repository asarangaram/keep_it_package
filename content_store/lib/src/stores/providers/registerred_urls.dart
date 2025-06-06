import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/registerred_urls.dart';

class RegisteredURLsNotifier extends AsyncNotifier<RegisteredURLs> {
  @override
  FutureOr<RegisteredURLs> build() {
    return RegisteredURLs();
  }

  StoreURL get activeStore => state.value!.activeStoreURL;
  set activeStore(StoreURL storeURL) =>
      state = AsyncValue.data(state.value!.setActiveStore(storeURL));
}

final registeredURLsProvider =
    AsyncNotifierProvider<RegisteredURLsNotifier, RegisteredURLs>(
        RegisteredURLsNotifier.new);
