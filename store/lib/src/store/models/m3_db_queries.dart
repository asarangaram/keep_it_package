// ignore_for_file: lines_longer_than_80_chars

import 'package:colan_widgets/colan_widgets.dart';

import 'm3_db_query.dart';

enum DBQueries {
  collectionById,
  tagById,
  mediaById,
  collectionByLabel,
  tagByLabel,
  collectionsAll,
  collectionsExcludeEmpty,
  collectionsByTagId,
  collectionsEmpty,
  collectionsByTagIDExcludeEmpty,
  tagsAll,
  tagsByCollectionId,
  tagsAllExcludeEmpty,
  tagsByCollectionIDExcludeEmpty,
  tagsByMediaId,
  mediaAll,
  mediaByCollectionId,
  mediaByTagId,
  mediaByPath,
  mediaByMD5;

  DBQuery<dynamic> get sql => switch (this) {
        collectionById => const DBQuery<Collection>(
            sql: 'SELECT * FROM Collection WHERE id = ? ',
            triggerOnTables: {'Collection'},
            fromMap: Collection.fromMap,
          ),
        tagById => const DBQuery<Tag>(
            sql: 'SELECT * FROM Tag WHERE id = ? ',
            triggerOnTables: {'Tag'},
            fromMap: Tag.fromMap,
          ),
        mediaById => const DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE id = ?',
            triggerOnTables: {'Item'},
            fromMap: CLMedia.fromMap,
          ),
        collectionByLabel => const DBQuery<Collection>(
            sql: 'SELECT * FROM Collection WHERE label = ? ',
            triggerOnTables: {'Collection'},
            fromMap: Collection.fromMap,
          ),
        tagByLabel => const DBQuery<Tag>(
            sql: 'SELECT * FROM Tag WHERE label = ? ',
            triggerOnTables: {'Tag'},
            fromMap: Tag.fromMap,
          ),
        collectionsAll => const DBQuery<Collection>(
            sql: 'SELECT * FROM Collection',
            triggerOnTables: {'Collection'},
            fromMap: Collection.fromMap,
          ),
        collectionsExcludeEmpty => const DBQuery<Collection>(
            sql: 'SELECT DISTINCT Collection.* FROM Collection '
                'JOIN Item ON Collection.id = Item.collectionId;',
            triggerOnTables: {'Collection', 'Item'},
            fromMap: Collection.fromMap,
          ),
        collectionsEmpty => const DBQuery<Collection>(
            sql: 'SELECT Collection.* FROM Collection '
                'LEFT JOIN Item ON Collection.id = Item.collectionId '
                'WHERE Item.collectionId IS NULL;',
            triggerOnTables: {'Collection', 'Item'},
            fromMap: Collection.fromMap,
          ),
        collectionsByTagId => const DBQuery<Collection>(
            sql: 'SELECT DISTINCT Collection.* '
                'FROM Collection '
                'JOIN TagCollection ON Collection.id = TagCollection.collectionId '
                'WHERE TagCollection.tagId = :tagId',
            triggerOnTables: {'Collection', 'Item'},
            fromMap: Collection.fromMap,
          ),
        collectionsByTagIDExcludeEmpty => const DBQuery<Collection>(
            sql: 'SELECT DISTINCT Collection.* '
                'FROM Collection '
                'JOIN Item ON Collection.id = Item.collectionId '
                'JOIN TagCollection ON Collection.id = TagCollection.collectionId '
                'WHERE TagCollection.tagId = :tagId;',
            triggerOnTables: {'Collection', 'Item', 'TagCollection'},
            fromMap: Collection.fromMap,
          ),
        tagsAll => const DBQuery<Tag>(
            sql: 'SELECT * FROM Tag',
            triggerOnTables: {'Tag'},
            fromMap: Tag.fromMap,
          ),
        tagsAllExcludeEmpty => const DBQuery<Tag>(
            sql: 'SELECT DISTINCT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tagId '
                'JOIN Collection ON TagCollection.collectionId = Collection.id '
                'JOIN Item ON Collection.id = Item.collectionId ',
            triggerOnTables: {
              'Tag',
              'TagCollection',
              'Collection',
              'Item',
            },
            fromMap: Tag.fromMap,
          ),
        tagsByCollectionId => const DBQuery<Tag>(
            sql: 'SELECT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tagId '
                'WHERE TagCollection.collectionId = ?',
            triggerOnTables: {'Tag', 'TagCollection'},
            fromMap: Tag.fromMap,
          ),
        tagsByCollectionIDExcludeEmpty => const DBQuery<Tag>(
            sql: 'SELECT DISTINCT Tag.* '
                'FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tagId '
                'JOIN Collection ON TagCollection.collectionId = Collection.id '
                'JOIN Item ON Collection.id = Item.collectionId '
                'WHERE TagCollection.collectionId = ? ',
            triggerOnTables: {
              'Tag',
              'TagCollection',
              'Collection',
              'Item',
            },
            fromMap: Tag.fromMap,
          ),
        mediaAll => const DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item',
            triggerOnTables: {'Item'},
            fromMap: CLMedia.fromMap,
          ),
        mediaByCollectionId => const DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE collectionId = ?',
            triggerOnTables: {'Item'},
            fromMap: CLMedia.fromMap,
          ),
        mediaByTagId => const DBQuery<CLMedia>(
            sql: 'SELECT Item.* '
                'FROM Item '
                'JOIN Collection ON Item.collectionId = Collection.id '
                'JOIN TagCollection ON Collection.id = TagCollection.collectionId '
                'WHERE TagCollection.tagId =? ',
            triggerOnTables: {'Item', 'Collection', 'TagCollection'},
            fromMap: CLMedia.fromMap,
          ),
        tagsByMediaId => const DBQuery<Tag>(
            sql: 'SELECT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tagId '
                'JOIN Item ON TagCollection.collectionId = Item.collectionId '
                'WHERE Item.id = ? ',
            triggerOnTables: {'Tag', 'TagCollection', 'Item'},
            fromMap: Tag.fromMap,
          ),
        mediaByMD5 => const DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE md5String = ?',
            triggerOnTables: {'Item'},
            fromMap: CLMedia.fromMap,
          ),
        mediaByPath => const DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE path = ?',
            triggerOnTables: {'Item'},
            fromMap: CLMedia.fromMap,
          ),
      };
}
