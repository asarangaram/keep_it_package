import 'package:background_downloader/background_downloader.dart';
import 'package:content_store/online_service/models/cl_server.dart';
import 'package:content_store/online_service/models/server.dart';
import 'package:content_store/online_service/models/server_media.dart';
import 'package:content_store/online_service/providers/downloader.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';

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

    /* test('can post to server?', () async {
      // print('can post to server?');

      expect(
        await server.hasConnection(),
        true,
        reason: 'Test cant proceed if the server is not online',
      );

      final media = ServerUploadEntity(
        path: 'test_images/5.jpeg',
        name: 'test image 5',
        collectionLabel: 'serverTest',
        createdDate: DateTime.now(),
        updatedDate: DateTime.now(),
        isDeleted: false,
      );

      final received = await Server.upsertMedia(
        media,
        server: server,
        downloader: downloader,
        mediaBaseDirectory: BaseDirectory.applicationSupport,
      );

      expect(received?.containsKey('serverUID'), true);
    }); */

    test('can update with PUT to server?', () async {
      // print('can post to server?');

      expect(
        await server.hasConnection(),
        true,
        reason: 'Test cant proceed if the server is not online',
      );

      final entity0 = ServerUploadEntity(
        path: 'test_images/5.jpeg',
        name: 'test image 5',
        collectionLabel: 'serverTest',
        createdDate: DateTime.now(),
        isDeleted: false,
      );

      final received0 = await Server.upsertMedia(
        entity0,
        server: server,
        downloader: downloader,
        mediaBaseDirectory: BaseDirectory.applicationSupport,
      );

      expect(received0?.containsKey('serverUID'), true);
      print(
        'successfully posted a media and got UID '
        '${received0!['serverUID'] as int}',
      );

      /* final entity1 = ServerUploadEntity.update(
        serverUID: received0!['serverUID'] as int,
        path: 'test_images/5_edited.jpeg',
        updatedDate: DateTime.now(),
      );
      final received1 = await Server.upsertMedia(
        entity1,
        server: server,
        
        downloader: downloader,
        mediaBaseDirectory: BaseDirectory.applicationSupport,
      );
      expect(received1?.containsKey('serverUID'), true); */
      final entity2 = ServerUploadEntity.update(
        serverUID: received0['serverUID'] as int,
        collectionLabel: 'Changed label',
        updatedDate: DateTime.now(),
      );
      final received1 = await Server.upsertMedia(
        entity2,
        server: server,
        downloader: downloader,
        mediaBaseDirectory: BaseDirectory.applicationSupport,
      );
      expect(received1?.containsKey('serverUID'), true);
    });
  });
}
