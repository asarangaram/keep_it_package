import 'package:colan_widgets/colan_widgets.dart';

import 'm3_db_query.dart';

enum DBQueries {
  collection,
  tag,
  media,
  collectionsAll,
  collectionsExcludeEmpty,
  collectionsByTagID,
  collectionsEmpty,
  collectionsByTagIDExcludeEmpty,
  tagsAll,
  tagsByCollectionID,
  tagsAllExcludeEmpty,
  tagsByCollectionIDExcludeEmpty,
  tagsByMediaID,
  mediaAll,
  mediaByCollectionID,
  mediaByTagID,
  mediaByMD5;

  DBQuery<dynamic> get sql => switch (this) {
        collection => const DBQuery(
            sql: 'SELECT * FROM Collection WHERE id = ? ',
            triggerOnTables: {'Collection'},
            fromMap: Collection.fromMap,
          ),
        tag => const DBQuery(
            sql: 'SELECT * FROM Tag WHERE id = ? ',
            triggerOnTables: {'Tag'},
            fromMap: Tag.fromMap,
          ),
        media => const DBQuery(
            sql: 'SELECT * FROM Item WHERE id = ?',
            triggerOnTables: {'Item'},
            fromMap: CLMedia.fromMap,
          ),
        collectionsAll => const DBQuery(
            sql: 'SELECT * FROM Collection',
            triggerOnTables: {'Collection'},
            fromMap: Collection.fromMap,
          ),
        collectionsExcludeEmpty => const DBQuery(
            sql: 'SELECT DISTINCT Collection.* FROM Collection '
                'JOIN Item ON Collection.id = Item.collection_id;',
            triggerOnTables: {'Collection', 'Item'},
            fromMap: Collection.fromMap,
          ),
        collectionsEmpty => const DBQuery(
            sql: 'SELECT Collection.* FROM Collection '
                'LEFT JOIN Item ON Collection.id = Item.collection_id '
                'WHERE Item.collection_id IS NULL;',
            triggerOnTables: {'Collection', 'Item'},
            fromMap: Collection.fromMap,
          ),
        collectionsByTagID => const DBQuery(
            sql: 'SELECT DISTINCT Collection.* '
                'FROM Collection '
                'JOIN TagCollection ON Collection.id = TagCollection.collection_id '
                'WHERE TagCollection.tag_id = :tagId',
            triggerOnTables: {'Collection', 'Item'},
            fromMap: Collection.fromMap,
          ),
        collectionsByTagIDExcludeEmpty => const DBQuery(
            sql: 'SELECT DISTINCT Collection.* '
                'FROM Collection '
                'JOIN Item ON Collection.id = Item.collection_id '
                'JOIN TagCollection ON Collection.id = TagCollection.collection_id '
                'WHERE TagCollection.tag_id = :tagId;',
            triggerOnTables: {'Collection', 'Item', 'TagCollection'},
            fromMap: Collection.fromMap,
          ),
        DBQueries.tagsAll => const DBQuery(
            sql: 'SELECT * FROM Tag',
            triggerOnTables: {'Tag'},
            fromMap: Tag.fromMap,
          ),
        DBQueries.tagsAllExcludeEmpty => const DBQuery(
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
        DBQueries.tagsByCollectionID => const DBQuery(
            sql: 'SELECT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tag_id '
                'WHERE TagCollection.collection_id = ?',
            triggerOnTables: {'Tag', 'TagCollection'},
            fromMap: Tag.fromMap,
          ),
        DBQueries.tagsByCollectionIDExcludeEmpty => const DBQuery(
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
        DBQueries.mediaAll => const DBQuery(
            sql: 'SELECT * FROM Item',
            triggerOnTables: {'Item'},
            fromMap: CLMedia.fromMap,
          ),
        DBQueries.mediaByCollectionID => const DBQuery(
            sql: 'SELECT * FROM Item WHERE collection_id = ?',
            triggerOnTables: {},
            fromMap: CLMedia.fromMap,
          ),
        DBQueries.mediaByTagID => const DBQuery(
            sql: 'SELECT Item.* '
                'FROM Item '
                'JOIN Collection ON Item.collection_id = Collection.id '
                'JOIN TagCollection ON Collection.id = TagCollection.collection_id '
                'WHERE TagCollection.tag_id =? ',
            triggerOnTables: {},
            fromMap: CLMedia.fromMap,
          ),
        DBQueries.tagsByMediaID => const DBQuery(
            sql: 'SELECT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tag_id '
                'JOIN Item ON TagCollection.collection_id = Item.collection_id '
                'WHERE Item.id = ? ',
            triggerOnTables: {'Tag', 'TagCollection', 'Item'},
            fromMap: Tag.fromMap,
          ),
        DBQueries.mediaByMD5 => const DBQuery(
            sql: 'SELECT * FROM Item WHERE md5String = ?',
            triggerOnTables: {'Item'},
            fromMap: Tag.fromMap,
          ),
      };
}
