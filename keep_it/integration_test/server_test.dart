import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:content_store/online_service/models/cl_server.dart';
import 'package:content_store/online_service/models/server.dart';

import 'package:content_store/online_service/models/server_upload_entity.dart';
import 'package:content_store/online_service/providers/downloader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:store/store.dart';

import 'fake_paths.dart';

void main() {
  late final CLServer server;
  late final DownloaderNotifier downloader;

  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  PathProviderPlatform.instance = FakePathProviderPlatform();
  server = const CLServer(name: 'udesktop.local.', port: 5000, id: 100);
  downloader = DownloaderNotifier();

  group('server: ', () {
    setUp(() {/** Nothing to do for now. */});
    test('is online?', () async {
      expect(await server.hasConnection(), true);
    });

    test('server transactions for a image', () async {
      const image = 'test_images/5.jpeg';
      const edittedImage = 'test_images/5_edited.jpeg';
      final directory = await getApplicationSupportDirectory();
      final imagePath = join(directory.path, image);
      final edittedImagePath = join(directory.path, edittedImage);

      expect(
        await server.hasConnection(),
        true,
        reason: 'Test cant proceed if the server is not online',
      );

      final createdDate = DateTime.now();
      final int serverUID;
      final Map<String, dynamic>? referenceMap;
      {
        final entity0 = ServerUploadEntity(
          path: image,
          name: 'test image 5',
          collectionLabel: 'serverTest',
          createdDate: createdDate,
          isDeleted: false,
        );

        referenceMap = await Server.upsertMedia(
          entity0,
          server: server,
          downloader: downloader,
          mediaBaseDirectory: BaseDirectory.applicationSupport,
        );

        expect(
          referenceMap?['serverUID'] != null,
          true,
          reason: 'failed to create the new media with test image',
        );
        serverUID = referenceMap!['serverUID'] as int;

        validate('create a media', referenceMap, {
          'createdDate': createdDate.millisecondsSinceEpoch,
          'md5String': await File(imagePath).checksum,
        });
      }
      {
        final updatedDate = DateTime.now();
        final entity1 = ServerUploadEntity.update(
          serverUID: serverUID,
          path: edittedImage,
          updatedDate: updatedDate,
        );
        final received1 = await Server.upsertMedia(
          entity1,
          server: server,
          downloader: downloader,
          mediaBaseDirectory: BaseDirectory.applicationSupport,
        );
        referenceMap['md5String'] = await File(edittedImagePath).checksum;
        referenceMap['updatedDate'] = updatedDate.millisecondsSinceEpoch;
        validate('edit the media', received1, referenceMap);
      }
      {
        const collectionLabel = 'Changed label';
        final updatedDate = DateTime.now();
        final entity2 = ServerUploadEntity.update(
          serverUID: serverUID,
          collectionLabel: collectionLabel,
          updatedDate: updatedDate,
        );
        final received2 = await Server.upsertMedia(
          entity2,
          server: server,
          downloader: downloader,
          mediaBaseDirectory: BaseDirectory.applicationSupport,
        );
        referenceMap['collectionLabel'] = collectionLabel;
        referenceMap['updatedDate'] = updatedDate.millisecondsSinceEpoch;
        validate('update collectionLabel', received2, referenceMap);
      }

      //////////////////////////////////////////////////////////////////////////
      /// Confirm if we can soft delete the image
      {
        final updatedDate = DateTime.now();
        final entity3 = ServerUploadEntity.update(
          serverUID: serverUID,
          isDeleted: true,
          updatedDate: updatedDate,
        );
        final received3 = await Server.upsertMedia(
          entity3,
          server: server,
          downloader: downloader,
          mediaBaseDirectory: BaseDirectory.applicationSupport,
        );
        expect(received3?['serverUID'], serverUID);

        referenceMap['isDeleted'] = 1;
        referenceMap['updatedDate'] = updatedDate.millisecondsSinceEpoch;
        validate('soft delete', received3, referenceMap);
      }

      final received4 = await Server.deleteMedia(
        serverUID,
        server: server,
        downloader: downloader,
        mediaBaseDirectory: BaseDirectory.applicationSupport,
      );
      expect(received4, true);
    });
  });
}

void validate(
  String test,
  Map<String, dynamic>? map,
  Map<String, dynamic> reference,
) {
  expect(map != null, true, reason: '$test: received map is null');
  for (final k in reference.keys) {
    expect(
      map![k],
      reference[k],
      reason:
          '$test: mismatch: $k, expected: ${reference[k]}, actual: ${map[k]} ',
    );
  }
}
