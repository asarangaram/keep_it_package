import 'dart:io';

import 'package:local_store/src/m2_db_manager.dart';
import 'package:path/path.dart' as p;

import 'package:store/store.dart';
import 'package:test/test.dart';
import 'package:test_api/src/backend/invoker.dart';

const testArtifactsFolder = './testArtifacts';

void main() {
  group('Database operations', () {
    late DBManager dbManager;

    File getDBPath() {
      final test = Invoker.current!.liveTest;
      final testName = test.test.name;
      final testShortName =
          testName.replaceAll(RegExp(r'[\s\./]'), '_').toLowerCase();
      final dbName = 'test_db/$testShortName/$testShortName.db';
      final dbFile = File(p.join(testArtifactsFolder, dbName));
      return dbFile;
    }

    setUp(() async {
      final dbFile = getDBPath();
      if (dbFile.parent.existsSync()) {
        dbFile.parent.deleteSync(recursive: true);
      }

      dbFile.parent.createSync(recursive: true);

      dbManager =
          await DBManager.createInstances(dbpath: dbFile.path, onReload: () {});
    });

    tearDown(() async {
      dbManager.dispose();
      final dbFile = getDBPath();
      if (!dbFile.parent.existsSync()) {
        dbFile.parent.deleteSync(recursive: true);
      }
    });

    // Add more tests for other cases as needed
  });
}
