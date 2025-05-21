import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/uri_config.dart';
import 'persist_json.dart';

class UriConfigNotifier extends FamilyAsyncNotifier<UriConfig, Uri> {
  UriConfigNotifier();

  String get storeKey => arg.toString();

  @override
  FutureOr<UriConfig> build(Uri arg) async {
    final store = await ref.watch(internalJSONStoreprovider.future);
    final json = await store.load(
      storeKey,
      const UriConfig().toJson(),
    );
    return UriConfig.fromJson(json);
  }

  Future<void> onChange({
    int? quarterTurns,
    Duration? lastKnownPlayPosition,
  }) async {
    if (quarterTurns == null && lastKnownPlayPosition == null) return;
    final store = await ref.read(internalJSONStoreprovider.future);
    state = AsyncValue.data(
      state.value!.copyWith(
        quarterTurns: quarterTurns,
        lastKnownPlayPosition: lastKnownPlayPosition,
      ),
    );
    await store.save(storeKey, state.value!.toJson());
  }
}

final uriConfigurationProvider =
    AsyncNotifierProvider.family<UriConfigNotifier, UriConfig, Uri>(
  UriConfigNotifier.new,
);
