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
                'JOIN Item ON Collection.id = Item.collectionId;',
            triggerOnTables: const {'Collection', 'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                Collection.fromMap(map),
          ),
        collectionsEmpty => DBQuery<Collection>(
            sql: 'SELECT Collection.* FROM Collection '
                'LEFT JOIN Item ON Collection.id = Item.collectionId '
                'WHERE Item.collectionId IS NULL;',
            triggerOnTables: const {'Collection', 'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                Collection.fromMap(map),
          ),
        collectionsByTagId => DBQuery<Collection>(
            sql: 'SELECT DISTINCT Collection.* '
                'FROM Collection '
                'JOIN TagCollection ON Collection.id = TagCollection.collectionId '
                'WHERE TagCollection.tagId = :tagId',
            triggerOnTables: const {'Collection', 'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                Collection.fromMap(map),
          ),
        collectionsByTagIDExcludeEmpty => DBQuery<Collection>(
            sql: 'SELECT DISTINCT Collection.* '
                'FROM Collection '
                'JOIN Item ON Collection.id = Item.collectionId '
                'JOIN TagCollection ON Collection.id = TagCollection.collectionId '
                'WHERE TagCollection.tagId = :tagId;',
            triggerOnTables: const {'Collection', 'Item', 'TagCollection'},
            fromMap: (map, {required appSettings, required validate}) =>
                Collection.fromMap(map),
          ),
        tagsAll => DBQuery<Tag>(
            sql: 'SELECT * FROM Tag',
            triggerOnTables: const {'Tag'},
            fromMap: (map, {required appSettings, required validate}) =>
                Tag.fromMap(map),
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
            fromMap: (map, {required appSettings, required validate}) =>
                Tag.fromMap(map),
          ),
        tagsByCollectionId => DBQuery<Tag>(
            sql: 'SELECT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tagId '
                'WHERE TagCollection.collectionId = ?',
            triggerOnTables: const {'Tag', 'TagCollection'},
            fromMap: (map, {required appSettings, required validate}) =>
                Tag.fromMap(map),
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
            fromMap: (map, {required appSettings, required validate}) =>
                Tag.fromMap(map),
          ),
        mediaAll => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item',
            triggerOnTables: const {'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                CLMedia.fromMap(
              map,
              pathPrefix: appSettings.directories.docDir.path,
              validate: validate,
            ),
          ),
        mediaByCollectionId => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE collectionId = ?',
            triggerOnTables: const {'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                CLMedia.fromMap(
              map,
              pathPrefix: appSettings.directories.docDir.path,
              validate: validate,
            ),
          ),
        mediaByTagId => DBQuery<CLMedia>(
            sql: 'SELECT Item.* '
                'FROM Item '
                'JOIN Collection ON Item.collectionId = Collection.id '
                'JOIN TagCollection ON Collection.id = TagCollection.collectionId '
                'WHERE TagCollection.tagId =? ',
            triggerOnTables: const {'Item', 'Collection', 'TagCollection'},
            fromMap: (map, {required appSettings, required validate}) =>
                CLMedia.fromMap(
              map,
              pathPrefix: appSettings.directories.docDir.path,
              validate: validate,
            ),
          ),
        tagsByMediaId => DBQuery<Tag>(
            sql: 'SELECT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tagId '
                'JOIN Item ON TagCollection.collectionId = Item.collectionId '
                'WHERE Item.id = ? ',
            triggerOnTables: const {'Tag', 'TagCollection', 'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                Tag.fromMap(map),
          ),
        mediaByMD5 => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE md5String = ?',
            triggerOnTables: const {'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                CLMedia.fromMap(
              map,
              pathPrefix: appSettings.directories.docDir.path,
              validate: validate,
            ),
          ),
        mediaByPath => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE path = ?',
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
