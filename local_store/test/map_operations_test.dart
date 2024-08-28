import 'package:local_store/src/map_operations.dart';
import 'package:test/test.dart';

void main() {
  group('MapDiff', () {
    test(
        'should correctly identify added, deleted, and '
        'changed items with various data types', () {
      final oldMap = {
        'int': 1,
        'float': 2.5,
        'string': 'hello',
        'list': [1, 2, 3],
      };
      final newMap = {
        'int': 1,
        'float': 3.5, // Changed
        'string': 'world', // Changed
        'list': [1, 2], // Modified (List shortened)
        'bool': true, // Added
      };

      final diff = MapDiff.scan(oldMap, newMap);

      expect(diff.added, equals({'bool': true}));
      expect(diff.deleted, equals({}));
      expect(
        diff.changed,
        equals({
          'float': 3.5,
          'string': 'world',
          'list': [1, 2],
        }),
      );
    });

    test('should handle maps with integer values', () {
      final oldMap = {'a': 1, 'b': 2};
      final newMap = {'a': 1, 'b': 3}; // Modified

      final diff = MapDiff.scan(oldMap, newMap);

      expect(diff.added, isEmpty);
      expect(diff.deleted, isEmpty);
      expect(diff.changed, equals({'b': 3}));
    });

    test('should handle maps with float values', () {
      final oldMap = {'a': 1.1, 'b': 2.2};
      final newMap = {'a': 1.1, 'b': 2.3}; // Modified

      final diff = MapDiff.scan(oldMap, newMap);

      expect(diff.added, isEmpty);
      expect(diff.deleted, isEmpty);
      expect(diff.changed, equals({'b': 2.3}));
    });

    test('should handle maps with string values', () {
      final oldMap = {'a': 'foo', 'b': 'bar'};
      final newMap = {'a': 'foo', 'b': 'baz'}; // Modified

      final diff = MapDiff.scan(oldMap, newMap);

      expect(diff.added, isEmpty);
      expect(diff.deleted, isEmpty);
      expect(diff.changed, equals({'b': 'baz'}));
    });

    test('should handle maps with list values', () {
      final oldMap = {
        'a': [1, 2],
        'b': [3, 4],
      };
      final newMap = {
        'a': [1, 2],
        'b': [4, 5],
      }; // Modified

      final diff = MapDiff.scan(oldMap, newMap);

      expect(diff.added, isEmpty);
      expect(diff.deleted, isEmpty);
      expect(
        diff.changed,
        equals({
          'b': [4, 5],
        }),
      );
    });

    test('should handle maps with mixed data types', () {
      final oldMap = {
        'int': 1,
        'float': 2.5,
        'string': 'hello',
        'list': [1, 2, 3],
      };
      final newMap = {
        'int': 2, // Changed
        'float': 2.5,
        'string': 'hello',
        'list': [1, 2, 4], // Modified (List changed)
        'bool': false, // Added
      };

      final diff = MapDiff.scan(oldMap, newMap);

      expect(diff.added, equals({'bool': false}));
      expect(diff.deleted, equals({}));
      expect(
        diff.changed,
        equals({
          'int': 2,
          'list': [1, 2, 4],
        }),
      );
    });

    test('should handle maps where values are null', () {
      final oldMap = {'a': null, 'b': 2};
      final newMap = {'a': 1, 'b': 2}; // Modified

      final diff = MapDiff.scan(oldMap, newMap);

      expect(diff.added, isEmpty);
      expect(diff.deleted, isEmpty);
      expect(diff.changed, equals({'a': 1}));
    });

    test('diffMap should contain added and changed items only', () {
      final oldMap = {
        'a': 1,
        'b': 2.5,
        'c': 'hello',
        'd': [1, 2],
      };
      final newMap = {
        'a': 2,
        'b': 2.5,
        'c': 'world', // Changed
        'e': true, // Added
      };

      final diff = MapDiff.scan(oldMap, newMap);

      expect(diff.diffMap, equals({'a': 2, 'c': 'world', 'e': true}));
    });

    test('diffMapFull should contain added, changed, and deleted items', () {
      final oldMap = {
        'a': 1,
        'b': 2.5,
        'c': 'hello',
        'd': [1, 2],
      };
      final newMap = {
        'a': 2,
        'b': 2.5,
        'c': 'world', // Changed
        'e': true, // Added
      };

      final diff = MapDiff.scan(oldMap, newMap);

      expect(
        diff.diffMapFull,
        equals({
          'a': 2,
          'c': 'world',
          'd': null, // Deleted
          'e': true,
        }),
      );
    });
  });
}
