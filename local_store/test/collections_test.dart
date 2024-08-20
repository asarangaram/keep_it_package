import 'dart:io';

import 'package:local_store/src/m2_db_manager.dart';
import 'package:path/path.dart' as p;

import 'package:store/store.dart';
import 'package:test/test.dart';
import 'package:test_api/src/backend/invoker.dart';

const testArtifactsFolder = './testArtifacts';

void main() {
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
  group('Collection table', () {
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

  group('CLMedia Tests', () {
    test(
      'upsertMedia - insert and update',
      () async {
        // Insert a new media item
        final media = CLMedia(
          path: 'path/to/media1',
          type: CLMediaType.image, // Adjust based on your enum or type
          md5String: 'md5hash1',
          collectionId: null,
        );

        final updated = await dbManager.upsertMedia(media);

        // Verify insertion
        expect(updated, isNotNull);
        final insertedMedia =
            await dbManager.dbReader.getMediaByID(updated!.id!);
        expect(insertedMedia?.path, equals('path/to/media1'));
        expect(insertedMedia?.md5String, equals('md5hash1'));

        // Update the media item
        final updatedMedia = insertedMedia!.copyWith(
          path: 'path/to/updated_media',
          md5String: 'md5hash2',
        );

        final updated2 = await dbManager.upsertMedia(updatedMedia);
        expect(updated2, isNotNull);
        // Verify update
        final fetchedMedia =
            await dbManager.dbReader.getMediaByID(updatedMedia.id!);
        expect(fetchedMedia?.path, equals('path/to/updated_media'));
        expect(fetchedMedia?.md5String, equals('md5hash2'));
      },
      timeout: const Timeout(Duration(minutes: 20)),
    );

    test('deleteMedia - delete media item', () async {
      // Insert a media item to delete
      final media = CLMedia(
        path: 'path/to/media_to_delete',
        type: CLMediaType.video,
        md5String: 'md5hash_to_delete',
        collectionId: null,
      );

      final updated = await dbManager.upsertMedia(media);

      expect(updated, isNotNull);

      // Ensure the media item is inserted
      final insertedMedia = await dbManager.dbReader.getMediaByID(updated!.id!);
      expect(insertedMedia?.path, equals('path/to/media_to_delete'));

      // Delete the media item
      await dbManager.deleteMedia(insertedMedia!, permanent: true);

      // Verify deletion
      final deletedMedia =
          await dbManager.dbReader.getMediaByID(insertedMedia.id!);
      expect(deletedMedia, isNull);
    });

    test('getMediaByID - retrieve media item', () async {
      // Insert a media item
      final media = CLMedia(
        path: 'path/to/media_for_retrieval',
        type: CLMediaType.audio,
        md5String: 'md5hash_for_retrieval',
        collectionId: null,
      );

      final updated = await dbManager.upsertMedia(media);

      expect(updated, isNotNull);
      // Retrieve the media item by ID
      final fetchedMedia = await dbManager.dbReader.getMediaByID(updated!.id!);

      // Verify retrieval
      expect(fetchedMedia, isNotNull);
      expect(fetchedMedia!.path, equals('path/to/media_for_retrieval'));
      expect(fetchedMedia.md5String, equals('md5hash_for_retrieval'));
    });

    test('upsertMedia - handle unique constraint violation', () async {
      // Insert a media item with a unique constraint
      final media1 = CLMedia(
        path: 'path/to/media_unique1',
        type: CLMediaType.image,
        md5String: 'md5hash_unique1',
        collectionId: null,
      );

      final updated1 = await dbManager.upsertMedia(media1);

      // Try to insert another media item with the same path and md5String
      final media2 = CLMedia(
        path: 'path/to/media_unique1',
        type: CLMediaType.image,
        md5String: 'md5hash_unique1',
        collectionId: null,
      );

      final updated2 = await dbManager.upsertMedia(media2);

      expect(updated2, updated1);
    });

    test('deleteMedia - handle non-existing media item', () async {
      // Try to delete a media item that does not exist
      final nonExistingMedia = CLMedia(
        id: 999,
        path: 'path/to/non_existing_media',
        type: CLMediaType.audio,
        md5String: 'md5hash_non_existing',
        collectionId: null,
      );

      // Expect no exception but no deletion should occur
      await dbManager.deleteMedia(nonExistingMedia, permanent: true);

      // Verify that no new media item was created
      final mediaAfterDeletion =
          await dbManager.dbReader.getMediaByID(nonExistingMedia.id!);
      expect(mediaAfterDeletion, isNull);
    });

    test('getMediaByID - handle non-existing media ID', () async {
      // Try to retrieve a media item with a non-existing ID
      const nonExistingId = 999; // Assuming -1 is not a valid ID
      final media = await dbManager.dbReader.getMediaByID(nonExistingId);

      // Expect the result to be null
      expect(media, isNull);
    });
  });
}
