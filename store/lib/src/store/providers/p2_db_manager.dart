import 'package:device_resources/device_resources.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import '../models/m2_db_manager.dart';
import '../models/store.dart';

final storeProvider = FutureProvider<Store>((ref) async {
  final appSettings = await ref.watch(appSettingsProvider.future);
  final dbPath = appSettings.directories.database;
  final fullPath = join(dbPath.pathString, appSettings.dbName);

  final storeInstance = await DBManager.createInstances(
    dbpath: fullPath,
    appSettings: appSettings,
  );
  ref.onDispose(storeInstance.dispose);
  return storeInstance;
});
