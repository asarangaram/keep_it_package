import 'dart:io';

import 'package:online_store/online_store.dart';
import 'package:path/path.dart';
import 'package:store/store.dart';
import 'package:test/test.dart';

import 'utils.dart';

void main() async {
  late CLServer server;
  late Directory tempDir;
  late int collectionId;

  setUpAll(() async {
    tempDir = await Directory.systemTemp.createTemp('image_test_dir_');
    print('Created temporary directory: ${tempDir.path}');
  });
  tearDownAll(() async {
    print('Deleting temporary directory: ${tempDir.path}');
    await tempDir.delete(recursive: true);
  });

  setUp(() async {
    try {
      final url = StoreURL(Uri.parse('http://127.0.0.1:5001'),
          identity: null, label: null);

      server = await CLServer(storeURL: url).withId();
      if (!server.hasID) {
        fail('Connection Failed, could not get the server Id');
      }

      final result = await server.createEntity(
          isCollection: true, label: 'Test Collection');
      result.when(
        validResponse: (result) {
          expect(result.containsKey('id'), true,
              reason: "response doesn't contains id");
          collectionId = result['id'] as int;
        },
        errorResponse: (error, {st}) {
          fail('$error');
        },
      );
    } catch (e) {
      fail('Failed: $e');
    }
  });
  tearDown(() async {
    // delete all the collection with it
    await server.deleteEntity({'id': collectionId});
  });
  group('Test Media Interface', () {
    test('Can create a media and update it with another media', () async {
      final filename = join(tempDir.path, 'img_${randomString(8)}.jpg');
      generateRandomPatternImage(filename);
      if (File(filename).existsSync()) {
        final result = await server.createEntity(
            isCollection: false,
            label: randomString(8),
            parentId: collectionId,
            fileName: filename);
        final id = result.when(
            validResponse: (data) {
              expect(data.containsKey('id'), true,
                  reason: 'Unable to create a media');

              return data['id'] as int;
            },
            errorResponse: (e, {st}) =>
                fail('failed to create media, Error: $e'));

        /// Try retriving:
        final retrive = await server.getEndpoint('/entity/$id');
        print(retrive);
      } else {
        fail('Unable to generate image file');
      }
    });
  });
}
