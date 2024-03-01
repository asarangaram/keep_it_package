// ignore_for_file: lines_longer_than_80_chars

import 'package:colan_widgets/colan_widgets.dart';
import 'package:store/src/store/models/cl_media.dart';

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
            preprocess: CLMediaDB.preprocessMediaMap,
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
                'JOIN Item ON Collection.id = Item.collection_id;',
            triggerOnTables: {'Collection', 'Item'},
            fromMap: Collection.fromMap,
          ),
        collectionsEmpty => const DBQuery<Collection>(
            sql: 'SELECT Collection.* FROM Collection '
                'LEFT JOIN Item ON Collection.id = Item.collection_id '
                'WHERE Item.collection_id IS NULL;',
            triggerOnTables: {'Collection', 'Item'},
            fromMap: Collection.fromMap,
          ),
        collectionsByTagId => const DBQuery<Collection>(
            sql: 'SELECT DISTINCT Collection.* '
                'FROM Collection '
                'JOIN TagCollection ON Collection.id = TagCollection.collection_id '
                'WHERE TagCollection.tag_id = :tagId',
            triggerOnTables: {'Collection', 'Item'},
            fromMap: Collection.fromMap,
          ),
        collectionsByTagIDExcludeEmpty => const DBQuery<Collection>(
            sql: 'SELECT DISTINCT Collection.* '
                'FROM Collection '
                'JOIN Item ON Collection.id = Item.collection_id '
                'JOIN TagCollection ON Collection.id = TagCollection.collection_id '
                'WHERE TagCollection.tag_id = :tagId;',
            triggerOnTables: {'Collection', 'Item', 'TagCollection'},
            fromMap: Collection.fromMap,
          ),
        DBQueries.tagsAll => const DBQuery<Tag>(
            sql: 'SELECT * FROM Tag',
            triggerOnTables: {'Tag'},
            fromMap: Tag.fromMap,
          ),
        DBQueries.tagsAllExcludeEmpty => const DBQuery<Tag>(
            sql: 'SELECT DISTINCT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tag_id '
                'JOIN Collection ON TagCollection.collection_id = Collection.id '
                'JOIN Item ON Collection.id = Item.collection_id ',
            triggerOnTables: {
              'Tag',
              'TagCollection',
              'Collection',
              'Item',
            },
            fromMap: Tag.fromMap,
          ),
        DBQueries.tagsByCollectionId => const DBQuery<Tag>(
            sql: 'SELECT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tag_id '
                'WHERE TagCollection.collection_id = ?',
            triggerOnTables: {'Tag', 'TagCollection'},
            fromMap: Tag.fromMap,
          ),
        DBQueries.tagsByCollectionIDExcludeEmpty => const DBQuery<Tag>(
            sql: 'SELECT DISTINCT Tag.* '
                'FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tag_id '
                'JOIN Collection ON TagCollection.collection_id = Collection.id '
                'JOIN Item ON Collection.id = Item.collection_id '
                'WHERE TagCollection.collection_id = ? ',
            triggerOnTables: {
              'Tag',
              'TagCollection',
              'Collection',
              'Item',
            },
            fromMap: Tag.fromMap,
          ),
        DBQueries.mediaAll => const DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item',
            triggerOnTables: {'Item'},
            fromMap: CLMedia.fromMap,
            preprocess: CLMediaDB.preprocessMediaMap,
          ),
        DBQueries.mediaByCollectionId => const DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE collection_id = ?',
            triggerOnTables: {},
            fromMap: CLMedia.fromMap,
            preprocess: CLMediaDB.preprocessMediaMap,
          ),
        DBQueries.mediaByTagId => const DBQuery<CLMedia>(
            sql: 'SELECT Item.* '
                'FROM Item '
                'JOIN Collection ON Item.collection_id = Collection.id '
                'JOIN TagCollection ON Collection.id = TagCollection.collection_id '
                'WHERE TagCollection.tag_id =? ',
            triggerOnTables: {},
            fromMap: CLMedia.fromMap,
            preprocess: CLMediaDB.preprocessMediaMap,
          ),
        DBQueries.tagsByMediaId => const DBQuery<Tag>(
            sql: 'SELECT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tag_id '
                'JOIN Item ON TagCollection.collection_id = Item.collection_id '
                'WHERE Item.id = ? ',
            triggerOnTables: {'Tag', 'TagCollection', 'Item'},
            fromMap: Tag.fromMap,
          ),
        DBQueries.mediaByMD5 => const DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE md5String = ?',
            triggerOnTables: {'Item'},
            fromMap: CLMedia.fromMap,
            preprocess: CLMediaDB.preprocessMediaMap,
          ),
      };
}
