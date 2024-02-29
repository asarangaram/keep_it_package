/* import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

import '../models/db_manager.dart';

final dbManagerProvider = FutureProvider<DBManager>((ref) async {
  final isDBPersist = ref.read(isDBPersistProvider);
  final DBManager dbManager;
  if (isDBPersist) {
    final appDir = await getApplicationDocumentsDirectory();
    final fullPath = path.join(appDir.path, 'keepIt.db');
    dbManager = DBManager(path: fullPath);
  } else {
    dbManager = DBManager();
  }
  ref.onDispose(dbManager.close);
  return dbManager;
});

final isDBPersistProvider = StateProvider<bool>((ref) {
  return true;
});
 */