import 'package:colan_services/colan_services.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:local_store/local_store.dart';
import 'package:path/path.dart';
import 'package:store/store.dart';

final storeProvider = FutureProvider<Store>((ref) async {
  final dbInstance = await ref.watch(dbInstanceProvider.future);
  final servers = ref.watch(serversProvider);

  final server = await servers.getMyServer();

  return dbInstance.attachServer(server);
});

final dbInstanceProvider = FutureProvider<Store>((ref) async {
  final appSettings = await ref.watch(appSettingsProvider.future);
  final dbPath = appSettings.directories.database;
  final fullPath = join(dbPath.pathString, appSettings.dbName);

  final storeInstance = await createStoreInstance(
    fullPath,
    onReload: ref.invalidateSelf,
    appSettings: appSettings,
  );
  ref.onDispose(storeInstance.dispose);
  return storeInstance;
});
