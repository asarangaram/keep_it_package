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
  mediaByMD5;

  DBQuery<dynamic> get sql => switch (this) {
        collectionById => DBQuery<Collection>(
            sql: 'SELECT * FROM Collection WHERE id = ? ',
            triggerOnTables: const {'Collection'},
            fromMap: (map, {required appSettings, required validate}) =>
                Collection.fromMap(map),
          ),
        tagById => DBQuery<Tag>(
            sql: 'SELECT * FROM Tag WHERE id = ? ',
            triggerOnTables: const {'Tag'},
            fromMap: (map, {required appSettings, required validate}) =>
                Tag.fromMap(map),
          ),
        mediaById => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE id = ?',
            triggerOnTables: const {'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                CLMedia.fromMap(
              map,
              pathPrefix: appSettings.directories.docDir.path,
              validate: validate,
            ),
          ),
        collectionByLabel => DBQuery<Collection>(
            sql: 'SELECT * FROM Collection WHERE label = ? ',
            triggerOnTables: const {'Collection'},
            fromMap: (map, {required appSettings, required validate}) =>
                Collection.fromMap(map),
          ),
        tagByLabel => DBQuery<Tag>(
            sql: 'SELECT * FROM Tag WHERE label = ? ',
            triggerOnTables: const {'Tag'},
            fromMap: (map, {required appSettings, required validate}) =>
                Tag.fromMap(map),
          ),
        collectionsAll => DBQuery<Collection>(
            sql: 'SELECT * FROM Collection',
            triggerOnTables: const {'Collection'},
            fromMap: (map, {required appSettings, required validate}) =>
                Collection.fromMap(map),
          ),
        collectionsExcludeEmpty => DBQuery<Collection>(
            sql: 'SELECT DISTINCT Collection.* FROM Collection '
                'JOIN Item ON Collection.id = Item.collection_id;',
            triggerOnTables: const {'Collection', 'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                Collection.fromMap(map),
          ),
        collectionsEmpty => DBQuery<Collection>(
            sql: 'SELECT Collection.* FROM Collection '
                'LEFT JOIN Item ON Collection.id = Item.collection_id '
                'WHERE Item.collection_id IS NULL;',
            triggerOnTables: const {'Collection', 'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                Collection.fromMap(map),
          ),
        collectionsByTagId => DBQuery<Collection>(
            sql: 'SELECT DISTINCT Collection.* '
                'FROM Collection '
                'JOIN TagCollection ON Collection.id = TagCollection.collection_id '
                'WHERE TagCollection.tag_id = :tagId',
            triggerOnTables: const {'Collection', 'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                Collection.fromMap(map),
          ),
        collectionsByTagIDExcludeEmpty => DBQuery<Collection>(
            sql: 'SELECT DISTINCT Collection.* '
                'FROM Collection '
                'JOIN Item ON Collection.id = Item.collection_id '
                'JOIN TagCollection ON Collection.id = TagCollection.collection_id '
                'WHERE TagCollection.tag_id = :tagId;',
            triggerOnTables: const {'Collection', 'Item', 'TagCollection'},
            fromMap: (map, {required appSettings, required validate}) =>
                Collection.fromMap(map),
          ),
        DBQueries.tagsAll => DBQuery<Tag>(
            sql: 'SELECT * FROM Tag',
            triggerOnTables: const {'Tag'},
            fromMap: (map, {required appSettings, required validate}) =>
                Tag.fromMap(map),
          ),
        DBQueries.tagsAllExcludeEmpty => DBQuery<Tag>(
            sql: 'SELECT DISTINCT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tag_id '
                'JOIN Collection ON TagCollection.collection_id = Collection.id '
                'JOIN Item ON Collection.id = Item.collection_id ',
            triggerOnTables: const {
              'Tag',
              'TagCollection',
              'Collection',
              'Item',
            },
            fromMap: (map, {required appSettings, required validate}) =>
                Tag.fromMap(map),
          ),
        DBQueries.tagsByCollectionId => DBQuery<Tag>(
            sql: 'SELECT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tag_id '
                'WHERE TagCollection.collection_id = ?',
            triggerOnTables: const {'Tag', 'TagCollection'},
            fromMap: (map, {required appSettings, required validate}) =>
                Tag.fromMap(map),
          ),
        DBQueries.tagsByCollectionIDExcludeEmpty => DBQuery<Tag>(
            sql: 'SELECT DISTINCT Tag.* '
                'FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tag_id '
                'JOIN Collection ON TagCollection.collection_id = Collection.id '
                'JOIN Item ON Collection.id = Item.collection_id '
                'WHERE TagCollection.collection_id = ? ',
            triggerOnTables: const {
              'Tag',
              'TagCollection',
              'Collection',
              'Item',
            },
            fromMap: (map, {required appSettings, required validate}) =>
                Tag.fromMap(map),
          ),
        DBQueries.mediaAll => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item',
            triggerOnTables: const {'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                CLMedia.fromMap(
              map,
              pathPrefix: appSettings.directories.docDir.path,
              validate: validate,
            ),
          ),
        DBQueries.mediaByCollectionId => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE collection_id = ?',
            triggerOnTables: const {},
            fromMap: (map, {required appSettings, required validate}) =>
                CLMedia.fromMap(
              map,
              pathPrefix: appSettings.directories.docDir.path,
              validate: validate,
            ),
          ),
        DBQueries.mediaByTagId => DBQuery<CLMedia>(
            sql: 'SELECT Item.* '
                'FROM Item '
                'JOIN Collection ON Item.collection_id = Collection.id '
                'JOIN TagCollection ON Collection.id = TagCollection.collection_id '
                'WHERE TagCollection.tag_id =? ',
            triggerOnTables: const {},
            fromMap: (map, {required appSettings, required validate}) =>
                CLMedia.fromMap(
              map,
              pathPrefix: appSettings.directories.docDir.path,
              validate: validate,
            ),
          ),
        DBQueries.tagsByMediaId => DBQuery<Tag>(
            sql: 'SELECT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tag_id '
                'JOIN Item ON TagCollection.collection_id = Item.collection_id '
                'WHERE Item.id = ? ',
            triggerOnTables: const {'Tag', 'TagCollection', 'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                Tag.fromMap(map),
          ),
        DBQueries.mediaByMD5 => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE md5String = ?',
            triggerOnTables: const {'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                CLMedia.fromMap(
              map,
              pathPrefix: appSettings.directories.docDir.path,
              validate: validate,
            ),
          ),
      };
}
