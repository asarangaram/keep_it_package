import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:keep_it/db/db.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

final dbManagerProvider = FutureProvider<DatabaseManager>((ref) async {
  final bool isDBPersist = ref.read(isDBPersistProvider);
  final DatabaseManager dbManager;
  if (isDBPersist) {
    final appDir = await getApplicationDocumentsDirectory();
    final fullPath = path.join(appDir.path, 'keepIt.db');
    dbManager = DatabaseManager(path: fullPath);
  } else {
    dbManager = DatabaseManager();
  }
  ref.onDispose(() => dbManager.close());
  return dbManager;
});

final isDBPersistProvider = StateProvider<bool>((ref) {
  return true;
});
