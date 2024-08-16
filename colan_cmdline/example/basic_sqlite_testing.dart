import 'dart:io';

import 'package:colan_cmdline/colan_cmdline.dart';
import 'package:store/store.dart';

Future<int> main() async {
  final dbFile = File('basic_sqlite_testing/basic_sqlite_testing.db');

  if (!dbFile.parent.existsSync()) {
    dbFile.parent.createSync(recursive: true);
  }
  if (dbFile.existsSync()) {
    dbFile.deleteSync();
  }
  final dbManager = await createServerCache(
    dbDir: './basic_sqlite_testing',
    onReload: () {},
    server: null,
    isOnline: null,
  );

  final collections = [
    Collection(
      label: 'my label 1',
      id: 1,
      createdDate: DateTime.now().add(const Duration(hours: 1)),
      updatedDate: DateTime.now().add(const Duration(hours: 1)),
    ),
    Collection(
      label: 'my label 2',
      id: 2,
      createdDate: DateTime.now().add(const Duration(hours: 2)),
      updatedDate: DateTime.now().add(const Duration(hours: 2)),
    ),
    Collection(
      label: 'my label 3',
      id: 3,
      createdDate: DateTime.now().add(const Duration(hours: 3)),
      updatedDate: DateTime.now().add(const Duration(hours: 3)),
    ),
    Collection(
      label: 'my label 4',
      id: 4,
      createdDate: DateTime.now().add(const Duration(hours: 4)),
      updatedDate: DateTime.now().add(const Duration(hours: 4)),
    ),
  ];
  for (final collection in collections) {
    await dbManager.upsertCollection(
      collection,
    );
  }
  final collections2 = [
    Collection(
      label: 'my label A',
      id: 1,
      createdDate: DateTime.now().add(const Duration(days: 2)),
      updatedDate: DateTime.now().add(const Duration(days: 2)),
    ),
    Collection(
      label: 'my label 4',
      id: 2,
      createdDate: DateTime.now().add(const Duration(days: 3)),
      updatedDate: DateTime.now().add(const Duration(days: 3)),
    ),
  ];
  for (final collection in collections2) {
    await dbManager.upsertCollection(
      collection,
    );
  }

  dbManager.dispose();

  return 0;
}
