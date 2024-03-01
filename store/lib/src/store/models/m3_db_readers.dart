// ignore_for_file: lines_longer_than_80_chars

import 'package:colan_widgets/colan_widgets.dart';

import 'm3_db_reader.dart';

enum DBReaders {
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

  DBReader<dynamic> get sql => switch (this) {
        collectionById => DBReader<Collection>(
            sql: 'SELECT * FROM Collection WHERE id = ? ',
            triggerOnTables: const {'Collection'},
            fromMap: (map, {required appSettings, required validate}) =>
                Collection.fromMap(map),
          ),
        tagById => DBReader<Tag>(
            sql: 'SELECT * FROM Tag WHERE id = ? ',
            triggerOnTables: const {'Tag'},
            fromMap: (map, {required appSettings, required validate}) =>
                Tag.fromMap(map),
          ),
        mediaById => DBReader<CLMedia>(
            sql: 'SELECT * FROM Item WHERE id = ?',
            triggerOnTables: const {'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                CLMedia.fromMap(
              map,
              pathPrefix: appSettings.directories.docDir.path,
              validate: validate,
            ),
          ),
        collectionByLabel => DBReader<Collection>(
            sql: 'SELECT * FROM Collection WHERE label = ? ',
            triggerOnTables: const {'Collection'},
            fromMap: (map, {required appSettings, required validate}) =>
                Collection.fromMap(map),
          ),
        tagByLabel => DBReader<Tag>(
            sql: 'SELECT * FROM Tag WHERE label = ? ',
            triggerOnTables: const {'Tag'},
            fromMap: (map, {required appSettings, required validate}) =>
                Tag.fromMap(map),
          ),
        collectionsAll => DBReader<Collection>(
            sql: 'SELECT * FROM Collection',
            triggerOnTables: const {'Collection'},
            fromMap: (map, {required appSettings, required validate}) =>
                Collection.fromMap(map),
          ),
        collectionsExcludeEmpty => DBReader<Collection>(
            sql: 'SELECT DISTINCT Collection.* FROM Collection '
                'JOIN Item ON Collection.id = Item.collectionId;',
            triggerOnTables: const {'Collection', 'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                Collection.fromMap(map),
          ),
        collectionsEmpty => DBReader<Collection>(
            sql: 'SELECT Collection.* FROM Collection '
                'LEFT JOIN Item ON Collection.id = Item.collectionId '
                'WHERE Item.collectionId IS NULL;',
            triggerOnTables: const {'Collection', 'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                Collection.fromMap(map),
          ),
        collectionsByTagId => DBReader<Collection>(
            sql: 'SELECT DISTINCT Collection.* '
                'FROM Collection '
                'JOIN TagCollection ON Collection.id = TagCollection.collectionId '
                'WHERE TagCollection.tagId = :tagId',
            triggerOnTables: const {'Collection', 'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                Collection.fromMap(map),
          ),
        collectionsByTagIDExcludeEmpty => DBReader<Collection>(
            sql: 'SELECT DISTINCT Collection.* '
                'FROM Collection '
                'JOIN Item ON Collection.id = Item.collectionId '
                'JOIN TagCollection ON Collection.id = TagCollection.collectionId '
                'WHERE TagCollection.tagId = :tagId;',
            triggerOnTables: const {'Collection', 'Item', 'TagCollection'},
            fromMap: (map, {required appSettings, required validate}) =>
                Collection.fromMap(map),
          ),
        DBReaders.tagsAll => DBReader<Tag>(
            sql: 'SELECT * FROM Tag',
            triggerOnTables: const {'Tag'},
            fromMap: (map, {required appSettings, required validate}) =>
                Tag.fromMap(map),
          ),
        DBReaders.tagsAllExcludeEmpty => DBReader<Tag>(
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
        DBReaders.tagsByCollectionId => DBReader<Tag>(
            sql: 'SELECT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tagId '
                'WHERE TagCollection.collectionId = ?',
            triggerOnTables: const {'Tag', 'TagCollection'},
            fromMap: (map, {required appSettings, required validate}) =>
                Tag.fromMap(map),
          ),
        DBReaders.tagsByCollectionIDExcludeEmpty => DBReader<Tag>(
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
        DBReaders.mediaAll => DBReader<CLMedia>(
            sql: 'SELECT * FROM Item',
            triggerOnTables: const {'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                CLMedia.fromMap(
              map,
              pathPrefix: appSettings.directories.docDir.path,
              validate: validate,
            ),
          ),
        DBReaders.mediaByCollectionId => DBReader<CLMedia>(
            sql: 'SELECT * FROM Item WHERE collectionId = ?',
            triggerOnTables: const {},
            fromMap: (map, {required appSettings, required validate}) =>
                CLMedia.fromMap(
              map,
              pathPrefix: appSettings.directories.docDir.path,
              validate: validate,
            ),
          ),
        DBReaders.mediaByTagId => DBReader<CLMedia>(
            sql: 'SELECT Item.* '
                'FROM Item '
                'JOIN Collection ON Item.collectionId = Collection.id '
                'JOIN TagCollection ON Collection.id = TagCollection.collectionId '
                'WHERE TagCollection.tagId =? ',
            triggerOnTables: const {},
            fromMap: (map, {required appSettings, required validate}) =>
                CLMedia.fromMap(
              map,
              pathPrefix: appSettings.directories.docDir.path,
              validate: validate,
            ),
          ),
        DBReaders.tagsByMediaId => DBReader<Tag>(
            sql: 'SELECT Tag.* FROM Tag '
                'JOIN TagCollection ON Tag.id = TagCollection.tagId '
                'JOIN Item ON TagCollection.collectionId = Item.collectionId '
                'WHERE Item.id = ? ',
            triggerOnTables: const {'Tag', 'TagCollection', 'Item'},
            fromMap: (map, {required appSettings, required validate}) =>
                Tag.fromMap(map),
          ),
        DBReaders.mediaByMD5 => DBReader<CLMedia>(
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
