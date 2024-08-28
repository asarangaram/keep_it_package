import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
import 'package:path/path.dart';
import 'package:store/store.dart';

/* final storeProvider = FutureProvider<Store>((ref) async {
  final appSettings = await ref.watch(appSettingsProvider.future);
  final db = appSettings.directories.db;
  final fullPath = join(db.pathString, appSettings.dbName);

  final storeInstance = await createStoreInstance(
    fullPath,
    onReload: ref.invalidateSelf,
  );
  ref.onDispose(storeInstance.dispose);
  return storeInstance;
}); */

@immutable
class StoreManager {
  const StoreManager({
    required this.store,
    required this.appSettings,
  });
  final Store store;
  final AppSettings appSettings;
}

class StoreNotifier extends StateNotifier<AsyncValue<StoreManager>> {
  StoreNotifier(this.ref) : super(const AsyncValue.loading()) {
    create();
  }
  final Ref ref;
  late final Store? storeInstance;

  Future<void> create() async {
    final appSettings = await ref.watch(appSettingsProvider.future);

    final db = appSettings.directories.db;
    final fullPath = join(db.pathString, appSettings.dbName);

    storeInstance = await createStoreInstance(
      fullPath,
      onReload: ref.invalidateSelf,
    );
    if (storeInstance != null) {
      state = const AsyncValue.loading();
      state = await AsyncValue.guard(() async {
        return StoreManager(store: storeInstance!, appSettings: appSettings);
      });
    }
  }

  @override
  void dispose() {
    storeInstance?.dispose();
    super.dispose();
  }
}

final storeProvider =
    StateNotifierProvider<StoreNotifier, AsyncValue<StoreManager>>((ref) {
  final notifier = StoreNotifier(ref);
  ref.onDispose(notifier.dispose);
  return notifier;
});
