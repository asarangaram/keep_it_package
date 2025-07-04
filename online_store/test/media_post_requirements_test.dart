import 'dart:convert';
import 'dart:io';

import 'package:online_store/online_store.dart';
import 'package:path/path.dart';
import 'package:store/store.dart';
import 'package:test/test.dart';

import 'collection_requirements_test.dart'
    show createCollection, deleteCollection;
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

      final result = await createCollection(server, label: 'Test Collection');
      expect(result.containsKey('id'), true,
          reason: "response doesn't contains id");
      collectionId = result['id'] as int;
    } catch (e) {
      fail('Failed: $e');
    }
  });
  tearDown(() async {
    // delete all the collection with it
    await deleteCollection({'id': collectionId});
  });
  group('Test Media Interface', () {
    test('Can create a media', () async {
      final filename = join(tempDir.path, 'img_${randomString(8)}.jpg');
      generateRandomPatternImage(filename);
      if (File(filename).existsSync()) {
        final result = await createMedia(server,
            label: randomString(8), parentId: collectionId, fileName: filename);
        expect(result.containsKey('id'), true,
            reason: 'Unable to create a media');
      } else {
        fail('Unable to generate image file');
      }
    });

    test("Can't create a media wihtout a file", () async {
      final result = await createMedia(
        server,
        label: randomString(8),
        parentId: collectionId,
      );
      expect(result.containsKey('id'), true,
          reason: 'Unable to create a media');
    });
  });
}

Future<Map<String, dynamic>> createMedia(CLServer server,
    {required String label,
    String? description,
    String? fileName,
    int? parentId,
    int? id}) async {
  try {
    final form = {
      'isCollection': '0',
      'label': label,
      if (description != null) 'description': description,
      if (parentId != null) 'parentId': parentId.toString()
    };
    final response =
        await server.post('/entity', fileName: fileName, form: form);
    return response.when(
        validResponse: (data) => jsonDecode(data) as Map<String, dynamic>,
        errorResponse: (e) {
          return fail('exception when creating a collection');
        });
  } catch (e) {
    fail('exception when creating a media');
  }
}
