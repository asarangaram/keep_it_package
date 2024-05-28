import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/m2_db_manager.dart';
import '../providers/p1_app_settings.dart';

final dbManagerProvider = FutureProvider<DBManager>((ref) async {
  final appSettings = await ref.watch(appSettingsProvider.future);

  final dbManager = await DBManager.createInstances(
    dbpath: appSettings.databaseFile.path,
    appSettings: appSettings,
  );
  ref.onDispose(dbManager.dispose);
  return dbManager;
});
