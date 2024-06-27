import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import '../models/m2_db_manager.dart';
import '../providers/p1_app_settings.dart';

final dbManagerProvider = FutureProvider<DBManager>((ref) async {
  final appSettings = await ref.watch(appSettingsProvider.future);
  final dbPath = appSettings.directories.database;
  final fullPath = join(dbPath.pathString, appSettings.dbName);

  final dbManager = await DBManager.createInstances(
    dbpath: fullPath,
    appSettings: appSettings,
  );
  ref.onDispose(dbManager.dispose);
  return dbManager;
});
