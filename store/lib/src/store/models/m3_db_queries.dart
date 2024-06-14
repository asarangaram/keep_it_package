// ignore_for_file: lines_longer_than_80_chars

import 'package:colan_widgets/colan_widgets.dart';

import 'm3_db_query.dart';

enum DBQueries {
  collectionById,
  collectionByLabel,
  collectionsAll,
  collectionsExcludeEmpty,
  collectionsEmpty,

  mediaById,
  mediaAll,
  mediaByCollectionId,
  mediaByPath,
  mediaByMD5,
  mediaPinned,
  mediaStaled,
  mediaDeleted,
  mediaByIdList,
  mediaByNoteID,
  notesAll,
  noteById,
  noteByPath,
  notesByMediaId;

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
            sql: 'SELECT * FROM Collection '
                "WHERE label NOT LIKE '***%'",
            triggerOnTables: const {'Collection'},
            fromMap: Collection.fromMap,
          ),
        collectionsExcludeEmpty => DBQuery<Collection>(
            sql: 'SELECT DISTINCT Collection.* FROM Collection '
                'JOIN Item ON Collection.id = Item.collectionId '
                "WHERE label NOT LIKE '***%' AND "
                'Item.isDeleted = 0',
            triggerOnTables: const {'Collection', 'Item'},
            fromMap: Collection.fromMap,
          ),
        collectionsEmpty => DBQuery<Collection>(
            sql: 'SELECT Collection.* FROM Collection '
                'LEFT JOIN Item ON Collection.id = Item.collectionId '
                'WHERE Item.collectionId IS NULL AND '
                "label NOT LIKE '***%' AND "
                'Item.isDeleted = 0',
            triggerOnTables: const {'Collection', 'Item'},
            fromMap: Collection.fromMap,
          ),
        mediaById => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE id = ?',
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMapNullable,
          ),
        mediaAll => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE isHidden IS 0 AND isDeleted IS 0',
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMapNullable,
          ),
        mediaByCollectionId => DBQuery<CLMedia>(
            sql:
                'SELECT * FROM Item WHERE collectionId = ? AND isHidden IS 0 AND isDeleted IS 0',
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMapNullable,
          ),
        mediaByMD5 => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE md5String = ?',
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMapNullable,
          ),
        mediaPinned => DBQuery<CLMedia>(
            sql:
                "SELECT * FROM Item WHERE NULLIF(pin, 'null') IS NOT NULL AND isHidden IS 0 AND isDeleted IS 0",
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMapNullable,
          ),
        mediaStaled => DBQuery<CLMedia>(
            sql:
                'SELECT * FROM Item WHERE isHidden IS NOT 0 AND isDeleted IS 0',
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMapNullable,
          ),
        mediaDeleted => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE isDeleted IS NOT 0 ',
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMapNullable,
          ),
        mediaByPath => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE path = ?',
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMapNullable,
          ),
        mediaByIdList => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE id IN (?)',
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMapNullable,
          ),
        mediaByNoteID => DBQuery<CLMedia>(
            sql:
                'SELECT Item.* FROM Item JOIN ItemNote ON Item.id = ItemNote.itemId WHERE ItemNote.noteId = ?;',
            triggerOnTables: const {'Item', 'Notes', 'ItemNote'},
            fromMap: CLMedia.fromMapNullable,
          ),
        notesAll => DBQuery<CLNote>(
            sql: 'SELECT * FROM Notes',
            triggerOnTables: const {'Notes'},
            fromMap: CLNote.fromMap2,
          ),
        noteById => DBQuery<CLNote>(
            sql: 'SELECT * FROM Notes WHERE id = ?;',
            triggerOnTables: const {'Notes'},
            fromMap: CLNote.fromMap2,
          ),
        noteByPath => DBQuery<CLNote>(
            sql: 'SELECT * FROM Notes WHERE path = ?;',
            triggerOnTables: const {'Notes'},
            fromMap: CLNote.fromMap2,
          ),
        notesByMediaId => DBQuery<CLNote>(
            sql:
                'SELECT Notes.* FROM Notes JOIN ItemNote ON Notes.id = ItemNote.noteId WHERE ItemNote.itemId = ?;',
            triggerOnTables: const {'Item', 'Notes', 'ItemNote'},
            fromMap: CLNote.fromMap2,
          ),
      };
}
