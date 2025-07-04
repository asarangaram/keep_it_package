import 'dart:convert';
import 'dart:io';

import 'package:online_store/online_store.dart';
import 'package:store/store.dart';
import 'package:test/test.dart';

import 'utils.dart';

/// Planned test
/// Try creating a collection with file
/// Try creating a collection with parentI

void main() async {
  late CLServer server;
  late Directory tempDir;

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
    } catch (e) {
      fail('Failed: $e');
    }
  });
  group('Test Collection Interface', () {
    test('Create Collection', () async {
      final label = randomString(8, prefix: 'test_');
      final desc = generateLoremIpsum();
      final result =
          await createCollection(server, label: label, description: desc);
      expect(result.containsKey('id'), true,
          reason: "response doesn't contains id");
      expect(result.containsKey('label'), true,
          reason: "response doesn't contains label");
      expect(result.containsKey('description'), true,
          reason: "response doesn't contains description");
      expect(result['label'], label, reason: 'label is not matching');
      expect(result['description'], desc,
          reason: 'description is not matching');
      await deleteCollection(result);
    });
    test('try creating Collection: same label, same description', () async {
      final label = randomString(8, prefix: 'test_');
      final desc = generateLoremIpsum();
      final Map<String, dynamic> reference;
      {
        final result =
            await createCollection(server, label: label, description: desc);
        expect(result.containsKey('id'), true,
            reason: "response doesn't contains id");
        expect(result.containsKey('label'), true,
            reason: "response doesn't contains label");
        expect(result.containsKey('description'), true,
            reason: "response doesn't contains description");
        expect(result['label'], label, reason: 'label is not matching');
        expect(result['description'], desc,
            reason: 'description is not matching');
        reference = result;
      }
      // Post again
      {
        final result =
            await createCollection(server, label: label, description: desc);
        expect(result.containsKey('id'), true,
            reason: "response doesn't contains id");
        expect(result.containsKey('label'), true,
            reason: "response doesn't contains label");
        expect(result.containsKey('description'), true,
            reason: "response doesn't contains description");
        expect(result['label'], label, reason: 'label is not matching');
        expect(result['description'], desc,
            reason: 'description is not matching');

        expect(result['id'], reference['id']);
        expect(result['label'], reference['label']);
        expect(result['description'], reference['description']);
      }
      await deleteCollection(reference);
    });

    test('try creating Collection: same label, different description',
        () async {
      final label = randomString(8, prefix: 'test_');

      final Map<String, dynamic> reference;
      {
        final desc = generateLoremIpsum();
        final result =
            await createCollection(server, label: label, description: desc);
        expect(result.containsKey('id'), true,
            reason: "response doesn't contains id");
        expect(result.containsKey('label'), true,
            reason: "response doesn't contains label");
        expect(result.containsKey('description'), true,
            reason: "response doesn't contains description");
        expect(result['label'], label, reason: 'label is not matching');
        expect(result['description'], desc,
            reason: 'description is not matching');
        reference = result;
      }
      // Post again
      {
        final desc = generateLoremIpsum();
        final result =
            await createCollection(server, label: label, description: desc);
        expect(result.containsKey('id'), true,
            reason: "response doesn't contains id");
        expect(result.containsKey('label'), true,
            reason: "response doesn't contains label");
        expect(result.containsKey('description'), true,
            reason: "response doesn't contains description");
        expect(result['label'], label, reason: 'label is not matching');

        /// Note, we should get the original description
        /// server should reject the description send now.
        /// This will ensure that post accidentally modify the description
        expect(result['description'], reference['description'],
            reason: 'description is not matching');
        expect(result, reference);

        expect(result['id'], reference['id']);
        expect(result['label'], reference['label']);
        expect(result['description'], reference['description']);
      }
      await deleteCollection(reference);
    });
  });
}

Future<Map<String, dynamic>> createCollection(CLServer server,
    {required String label, String? description}) async {
  try {
    final response = await server.post('/entity', fileName: null, form: {
      'isCollection': '1',
      'label': label,
      if (description != null) 'description': description,
    });
    return response.when(
        validResponse: (data) => jsonDecode(data) as Map<String, dynamic>,
        errorResponse: (e) {
          return fail('exception when creating a collection');
        });
  } catch (e) {
    fail('Unexpected Exception from server.post');
  }
}

Future<void> deleteCollection(Map<String, dynamic> map) async {
  // TODO
}
