import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
import 'package:path/path.dart';
import 'package:store/store.dart';

import '../../settings_service/providers/p1_app_settings.dart';
import '../models/store_manager.dart';

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
