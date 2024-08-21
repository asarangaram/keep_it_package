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
