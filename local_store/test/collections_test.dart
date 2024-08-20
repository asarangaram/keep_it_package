import 'dart:io';

import 'package:local_store/src/m2_db_manager.dart';
import 'package:path/path.dart';

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
      final dbFile = File(join(testArtifactsFolder, dbName));
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

    test('INSERT NEW COLLECTION', () async {
      final collection = Collection(
        label: 'Test Collection',
        description: 'Description',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      final result = await dbManager.upsertCollection(collection);

      // Add assertions to check the result
      expect(result.label, 'Test Collection');
    });
    test('UPSERT EXISTING COLLECTION', () async {
      final collection = Collection(
        label: 'Test Collection',
        description: 'Description',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      final result1 = await dbManager.upsertCollection(collection);
      final result2 =
          await dbManager.upsertCollection(collection.copyWith(id: result1.id));

      // Add assertions to check the result
      expect(result2.label, 'Test Collection');
      expect(result2.id, isNotNull);
      expect(result2.id, result1.id);
    });

/* 
    test('upsertCollection updates an existing collection', () async {
      final existingCollection = Collection(
        id: 1,
        label: 'Existing Collection',
        description: 'Old Description',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      // Insert an initial collection
      await upsertCollection(db, existingCollection);

      final updatedCollection = Collection(
        id: 1,
        label: 'Updated Collection',
        description: 'New Description',
        createdDate: existingCollection.createdDate,
        updatedDate: DateTime.now(),
      );

      final result = await upsertCollection(db, updatedCollection);

      // Check that the update was successful
      expect(result.label, equals('Updated Collection'));
      expect(result.description, equals('New Description'));
    });

    test('deleteCollection removes an existing collection', () async {
      final collection = Collection(
        id: 2,
        label: 'Collection to Delete',
        description: 'To be deleted',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      await upsertCollection(db, collection);
      await deleteCollection(db, collection);

      final result = await getCollectionByID(2);
      expect(result, isNull);
    });

    test('getCollectionByID returns null for non-existent ID', () async {
      final result = await getCollectionByID(999);
      expect(result, isNull);
    });

    test('upsertCollection handles database errors', () async {
      // Mock the database to throw an error
      // You may use a mock database or throw an exception to simulate an error
      // For example purposes, we'll just simulate an error
      try {
        await upsertCollection(
          db,
          Collection(
            label: 'Error Collection',
            description: 'Description',
            createdDate: DateTime.now(),
            updatedDate: DateTime.now(),
          ),
        );
        fail('Exception was not thrown');
      } catch (e) {
        expect(
          e,
          isA<DatabaseException>(),
        ); // Adjust this to your actual exception
      }
    }); */
  });
}
