import 'dart:io';
import 'package:device_resources/device_resources.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:local_store/local_store.dart';

import 'package:local_store/src/m2_db_manager.dart';
import 'package:mockito/annotations.dart';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import 'package:store/store.dart';
import 'package:test/test.dart';
import 'package:test_api/src/backend/invoker.dart';

const testArtifactsFolder = './testArtifacts';

const withIdResponseBody = '''
            {
                "id": 100,
                "info": "This is a test server",
                "name": "colan_server"
            }''';

const mockCollections = Collections([
  Collection(
    label: 'localCollection1',
    description: 'Description for new collection1',
  ),
  Collection(
    label: 'localCollection2',
    description: 'Description for new collection2',
  ),
  Collection(
    label: 'localCollection3',
    description: 'Description for new collection3',
  ),
]);

@GenerateNiceMocks([MockSpec<http.Client>()])
void main() {
  group('API Client testing', () {
    late DBManager dbManager;
    late MockClient mockClient;
    late String testShortName;

    File getDBPath() {
      final dbName = 'test_db/$testShortName/$testShortName.db';
      final dbFile = File(p.join(testArtifactsFolder, dbName));
      return dbFile;
    }

    setUp(() async {
      final test = Invoker.current!.liveTest;
      final testName = test.test.name;
      testShortName =
          testName.replaceAll(RegExp(r'[\s\./]'), '_').toLowerCase();
      final dbFile = getDBPath();
      if (dbFile.parent.existsSync()) {
        dbFile.parent.deleteSync(recursive: true);
      }

      dbFile.parent.createSync(recursive: true);
      const server = CLServerImpl(name: 'test_server', port: 5000);
      mockClient = MockClient((request) async {
        return switch (request.url.path) {
          '/collection' => http.Response(mockCollections.toJsonList(), 200),
          '' => http.Response(withIdResponseBody, 200),
          _ => http.Response('not handled by mock', 400),
        };
      });
      final serverWithID = await server.withId(client: mockClient);
      final directories = CLDirectories(
        persistent: await getApplicationDocumentsDirectory(),
        temporary: await getApplicationCacheDirectory(),
        systemTemp: Directory.systemTemp,
      );
      final appSettings = AppSettings(directories);
      dbManager = await DBManager.createInstances(
        dbpath: dbFile.path,
        onReload: () {},
        server: serverWithID,
        appSettings: appSettings,
      );
    });

    tearDown(() async {
      dbManager.dispose();
      final dbFile = getDBPath();
      if (!dbFile.parent.existsSync()) {
        dbFile.parent.deleteSync(recursive: true);
      }
    });

    test('can setup the dbManager with a server', () async {
      expect(dbManager.server?.id, 100);
    });

    /* test(
      'pull the content from server twice and update local db',
      () async {
        // Pull Once
        final result = await dbManager.pull(client: mockClient);
        expect(result, DBSyncStatus.success);

        final collectionsFromDB1 = await dbManager.dbReader.getCollectionAll();
        expect(collectionsFromDB1, isNotNull);

        final result2 = await dbManager.pull(client: mockClient);

        expect(result2, DBSyncStatus.success);
        final collectionsFromDB2 = await dbManager.dbReader.getCollectionAll();
        expect(collectionsFromDB2, isNotNull);

        expect(collectionsFromDB2, collectionsFromDB1);
      },
      timeout: const Timeout(Duration(minutes: 60)),
    ); */

    /* test('sync locally Modifed Collection', () async {
      for (final collection in collections) {
        await dbManager.upsertCollection(collection);
      }

      // ignore: unused_local_variable
      final updatedCollections =
          await dbManager.dbReader.locallyModifiedCollections();

      expect(updatedCollections.length, 3);
    }); */

    // Add more tests for other cases as needed
  });
}
