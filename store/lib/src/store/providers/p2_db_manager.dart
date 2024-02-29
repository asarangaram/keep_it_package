import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:store/src/store/models/m2_db_manager.dart';
import 'package:store/src/store/providers/p1_app_settings.dart';

final dbManagerProvider = FutureProvider<DBManager>((ref) async {
  final appSettings = await ref.watch(appSettingsProvider.future);
  final appDir = appSettings.directories.docDir;
  final fullPath = join(appDir.path, appSettings.dbName);
  return DBManager.createInstances(
    dbpath: fullPath,
  );
});
