import 'dart:convert';
import 'dart:io';

import 'package:online_store/online_store.dart';
import 'package:online_store/src/implementations/store_reply.dart';
import 'package:store/store.dart';
import 'package:test/test.dart';

import 'utils.dart';

/// Add Tests for
/// Creating a collection with file
/// Creating a collection with parentId

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
      final reply =
          await createCollection(server, label: label, description: desc);
      final reference = reply.when(
        validResponse: (result) {
          expect(result.containsKey('id'), true,
              reason: "response doesn't contains id");
          expect(result.containsKey('label'), true,
              reason: "response doesn't contains label");
          expect(result.containsKey('description'), true,
              reason: "response doesn't contains description");
          expect(result['label'], label, reason: 'label is not matching');
          expect(result['description'], desc,
              reason: 'description is not matching');
          return result;
        },
        errorResponse: (error, {st}) {
          fail('$error');
        },
      );
      await deleteCollection(reference);
    });
    test('try creating Collection: same label, same description', () async {
      final label = randomString(8, prefix: 'test_');
      final desc = generateLoremIpsum();
      final Map<String, dynamic> reference;
      {
        final reply =
            await createCollection(server, label: label, description: desc);
        reference = reply.when(
          validResponse: (result) {
            expect(result.containsKey('id'), true,
                reason: "response doesn't contains id");
            expect(result.containsKey('label'), true,
                reason: "response doesn't contains label");
            expect(result.containsKey('description'), true,
                reason: "response doesn't contains description");
            expect(result['label'], label, reason: 'label is not matching');
            expect(result['description'], desc,
                reason: 'description is not matching');
            return result;
          },
          errorResponse: (error, {st}) {
            fail('$error');
          },
        );
      }
      // Post again
      {
        final reply =
            await createCollection(server, label: label, description: desc);
        reply.when(
          validResponse: (result) {
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
            return result;
          },
          errorResponse: (error, {st}) {
            fail('$error');
          },
        );
      }
      await deleteCollection(reference);
    });

    test('try creating Collection: same label, different description',
        () async {
      final label = randomString(8, prefix: 'test_');

      final Map<String, dynamic> reference;
      {
        final desc = generateLoremIpsum();
        final reply =
            await createCollection(server, label: label, description: desc);

        reference = reply.when(
          validResponse: (result) {
            expect(result.containsKey('id'), true,
                reason: "response doesn't contains id");
            expect(result.containsKey('label'), true,
                reason: "response doesn't contains label");
            expect(result.containsKey('description'), true,
                reason: "response doesn't contains description");
            expect(result['label'], label, reason: 'label is not matching');
            expect(result['description'], desc,
                reason: 'description is not matching');
            return result;
          },
          errorResponse: (error, {st}) {
            fail('$error');
          },
        );
      }
      // Post again
      {
        final desc = generateLoremIpsum();
        final reply =
            await createCollection(server, label: label, description: desc);

        reply.when(
          validResponse: (result) {
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

            expect(result, reference, reason: 'response must match reference');
          },
          errorResponse: (error, {st}) {
            fail('$error');
          },
        );
      }
      await deleteCollection(reference);
    });
  });
}

Future<StoreReply<Map<String, dynamic>>> createCollection(CLServer server,
    {required String label, String? description}) async {
  try {
    final response = await server.post('/entity', fileName: null, form: {
      'isCollection': '1',
      'label': label,
      if (description != null) 'description': description,
    });
    return response.when(
        validResponse: (data) =>
            StoreResult(jsonDecode(data) as Map<String, dynamic>),
        errorResponse: (e, {st}) {
          return StoreError(e, st: st);
        });
  } catch (e) {
    fail('Unexpected Exception from server.post');
  }
}

Future<void> deleteCollection(Map<String, dynamic> map) async {
  // TODO
}
