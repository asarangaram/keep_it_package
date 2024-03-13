// ignore_for_file: lines_longer_than_80_chars

import 'package:colan_widgets/colan_widgets.dart';

import 'm3_db_query.dart';

enum DBQueries {
  collectionById,
  collectionByLabel,
  collectionsAll,
  collectionsExcludeEmpty,
  collectionsByTagId,
  collectionsEmpty,
  collectionsByTagIDExcludeEmpty,
  tagById,
  tagByLabel,
  tagsAll,
  tagsByCollectionId,
  tagsAllExcludeEmpty,
  tagsByCollectionIDExcludeEmpty,
  tagsByMediaId,
  mediaById,
  mediaAll,
  mediaByCollectionId,
  mediaByTagId,
  mediaByPath,
  mediaByMD5,
  mediaByIdList;

  DBQuery<dynamic> get sql => switch (this) {
        collectionById => DBQuery<Collection>(
            sql: 'SELECT * FROM Collection WHERE id = ? ',
            triggerOnTables: const {'Collection'},
            fromMap: Collection.fromMap,
          ),
        collectionByLabel => DBQuery<Collection>(
            sql: 'SELECT * FROM Collection WHERE label = ? ',
            triggerOnTables: const {'Collection'},
            fromMap: Collection.fromMap,
          ),
        collectionsAll => DBQuery<Collection>(
            sql: 'SELECT * FROM Collection',
            triggerOnTables: const {'Collection'},
            fromMap: Collection.fromMap,
          ),
        collectionsExcludeEmpty => DBQuery<Collection>(
            sql: 'SELECT DISTINCT Collection.* FROM Collection '
                'JOIN Item ON Collection.id = Item.collectionId;',
            triggerOnTables: const {'Collection', 'Item'},
            fromMap: Collection.fromMap,
          ),
        collectionsEmpty => DBQuery<Collection>(
            sql: 'SELECT Collection.* FROM Collection '
                'LEFT JOIN Item ON Collection.id = Item.collectionId '
                'WHERE Item.collectionId IS NULL;',
            triggerOnTables: const {'Collection', 'Item'},
            fromMap: Collection.fromMap,
          ),
        collectionsByTagId => DBQuery<Collection>(
            sql: 'SELECT DISTINCT Collection.* '
                'FROM Collection '
                'JOIN TagCollection ON Collection.id = TagCollection.collectionId '
                'WHERE TagCollection.tagId = :tagId',
            triggerOnTables: const {'Collection', 'Item'},
            fromMap: Collection.fromMap,
          ),
        collectionsByTagIDExcludeEmpty => DBQuery<Collection>(
            sql: 'SELECT DISTINCT Collection.* '
                'FROM Collection '
                'JOIN Item ON Collection.id = Item.collectionId '
                'JOIN TagCollection ON Collection.id = TagCollection.collectionId '
                'WHERE TagCollection.tagId = :tagId;',
            triggerOnTables: const {'Collection', 'Item', 'TagCollection'},
            fromMap: Collection.fromMap,
          ),
        tagById => DBQuery<Tag>(
            sql: 'SELECT * FROM Tag WHERE id = ? ',
            triggerOnTables: const {'Tag'},
            fromMap: Tag.fromMap,
          ),
        tagByLabel => DBQuery<Tag>(
            sql: 'SELECT * FROM Tag WHERE label = ? ',
            triggerOnTables: const {'Tag'},
            fromMap: Tag.fromMap,
          ),
        tagsAll => DBQuery<Tag>(
            sql: 'SELECT * FROM Tag',
            triggerOnTables: const {'Tag'},
            fromMap: Tag.fromMap,
          ),
        tagsAllExcludeEmpty => DBQuery<Tag>(
            sql: 'SELECT DISTINCT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tagId '
                'JOIN Collection ON TagCollection.collectionId = Collection.id '
                'JOIN Item ON Collection.id = Item.collectionId ',
            triggerOnTables: const {
              'Tag',
              'TagCollection',
              'Collection',
              'Item',
            },
            fromMap: Tag.fromMap,
          ),
        tagsByCollectionId => DBQuery<Tag>(
            sql: 'SELECT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tagId '
                'WHERE TagCollection.collectionId = ?',
            triggerOnTables: const {'Tag', 'TagCollection'},
            fromMap: Tag.fromMap,
          ),
        tagsByCollectionIDExcludeEmpty => DBQuery<Tag>(
            sql: 'SELECT DISTINCT Tag.* '
                'FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tagId '
                'JOIN Collection ON TagCollection.collectionId = Collection.id '
                'JOIN Item ON Collection.id = Item.collectionId '
                'WHERE TagCollection.collectionId = ? ',
            triggerOnTables: const {
              'Tag',
              'TagCollection',
              'Collection',
              'Item',
            },
            fromMap: Tag.fromMap,
          ),
        tagsByMediaId => DBQuery<Tag>(
            sql: 'SELECT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tagId '
                'JOIN Item ON TagCollection.collectionId = Item.collectionId '
                'WHERE Item.id = ? ',
            triggerOnTables: const {'Tag', 'TagCollection', 'Item'},
            fromMap: Tag.fromMap,
          ),
        mediaById => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE id = ?',
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMap,
          ),
        mediaAll => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item',
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMap,
          ),
        mediaByCollectionId => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE collectionId = ?',
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMap,
          ),
        mediaByTagId => DBQuery<CLMedia>(
            sql: 'SELECT Item.* '
                'FROM Item '
                'JOIN Collection ON Item.collectionId = Collection.id '
                'JOIN TagCollection ON Collection.id = TagCollection.collectionId '
                'WHERE TagCollection.tagId =? ',
            triggerOnTables: const {'Item', 'Collection', 'TagCollection'},
            fromMap: CLMedia.fromMap,
          ),
        mediaByMD5 => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE md5String = ?',
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMap,
          ),
        mediaByPath => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE path = ?',
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMap,
          ),
        mediaByIdList => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE id IN (?)',
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMap,
          ),
      };
}
