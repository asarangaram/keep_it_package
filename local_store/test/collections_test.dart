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

    test('Insert a Collection', () async {
      final collection = Collection(
        label: 'New Collection',
        description: 'Description for new collection',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      final insertedCollection = await dbManager.upsertCollection(collection);
      expect(insertedCollection.label, equals('New Collection'));
      expect(
        insertedCollection.description,
        equals('Description for new collection'),
      );

      // Ensure the ID is not null
      expect(insertedCollection.id, isNotNull);
    });

    test('Delete a Collection', () async {
      final collection = Collection(
        label: 'Collection to Delete',
        description: 'To be deleted',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      final insertedCollection = await dbManager.upsertCollection(collection);

      await dbManager.deleteCollection(insertedCollection);

      final result =
          await dbManager.dbReader.getCollectionByID(insertedCollection.id!);
      expect(result, isNull);
    });

    test('Update a Collection with ID', () async {
      final collection = Collection(
        label: 'Initial Collection',
        description: 'Initial Description',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      final insertedCollection = await dbManager.upsertCollection(collection);

      final updatedCollection = Collection(
        id: insertedCollection.id, // Use auto-generated ID
        label: 'Updated Collection',
        description: 'Updated Description',
        createdDate: insertedCollection.createdDate,
        updatedDate: DateTime.now(),
      );

      final result = await dbManager.upsertCollection(updatedCollection);
      expect(result.label, equals('Updated Collection'));
      expect(result.description, equals('Updated Description'));
    });

    test('Update Multiple Columns with ID', () async {
      final collection = Collection(
        label: 'Old Collection',
        description: 'Old Description',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      final insertedCollection = await dbManager.upsertCollection(collection);

      final updatedCollection = Collection(
        id: insertedCollection.id, // Use auto-generated ID
        label: 'New Collection',
        description: 'New Description',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      final result = await dbManager.upsertCollection(updatedCollection);
      expect(result.label, equals('New Collection'));
      expect(result.description, equals('New Description'));
    });

    test('Delete a Collection and Confirm', () async {
      final collection = Collection(
        label: 'Collection to Confirm Deletion',
        description: 'To be confirmed',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      final insertedCollection = await dbManager.upsertCollection(collection);
      await dbManager.deleteCollection(insertedCollection);

      final result =
          await dbManager.dbReader.getCollectionByID(insertedCollection.id!);
      expect(result, isNull);
    });

    test('Try Updating a Non-Existing Collection', () async {
      const nonExistingId = 999999; // A likely non-existent ID
      final nonExistingCollection = Collection(
        id: nonExistingId,
        label: 'Non-Existing Collection',
        description: 'Should not exist',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      try {
        await dbManager.upsertCollection(nonExistingCollection);
      } catch (e) {
        expect(e, isA<Exception>()); // Adjust based on your exception handling
      }
    });

    test('Try Deleting a Non-Existing Collection', () async {
      const nonExistingId = 999999; // A likely non-existent ID
      final nonExistingCollection = Collection(
        id: nonExistingId,
        label: 'Non-Existing Collection',
        description: 'Should not exist',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      try {
        await dbManager.deleteCollection(nonExistingCollection);
        final result =
            await dbManager.dbReader.getCollectionByID(nonExistingId);
        expect(result, isNull);
      } catch (e) {
        expect(e, isA<Exception>()); // Adjust based on your exception handling
      }
    });

    test('Query for a Collection', () async {
      final collection = Collection(
        label: 'Query Collection',
        description: 'Description for query',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      final insertedCollection = await dbManager.upsertCollection(collection);
      final result =
          await dbManager.dbReader.getCollectionByID(insertedCollection.id!);
      expect(result, isNotNull);
      expect(result?.label, equals('Query Collection'));
    });

    test('Check Uniqueness of Unique Fields', () async {
      final collection1 = Collection(
        label: 'Unique Collection',
        description: 'Description 1',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      final collection2 = Collection(
        label: 'Unique Collection', // Same label
        description: 'Description 2',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
      );

      await dbManager.upsertCollection(collection1);

      try {
        await dbManager.upsertCollection(collection2);
        fail('Exception was not thrown');
      } catch (e) {
        expect(e, isA<Exception>()); // Adjust based on your exception handling
      }
    });

    // Add more tests for other cases as needed
  });
}
