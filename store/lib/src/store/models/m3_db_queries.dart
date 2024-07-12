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
  notesByMediaId,
  notesOrphan;

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
            fromMap: CLMedia.fromMap,
          ),
        mediaAll => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE isHidden IS 0 AND isDeleted IS 0',
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMap,
          ),
        mediaByCollectionId => DBQuery<CLMedia>(
            sql:
                'SELECT * FROM Item WHERE collectionId = ? AND isHidden IS 0 AND isDeleted IS 0',
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMap,
          ),
        mediaByMD5 => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE md5String = ?',
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMap,
          ),
        mediaPinned => DBQuery<CLMedia>(
            sql:
                "SELECT * FROM Item WHERE NULLIF(pin, 'null') IS NOT NULL AND isHidden IS 0 AND isDeleted IS 0",
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMap,
          ),
        mediaStaled => DBQuery<CLMedia>(
            sql:
                'SELECT * FROM Item WHERE isHidden IS NOT 0 AND isDeleted IS 0',
            triggerOnTables: const {'Item'},
            fromMap: CLMedia.fromMap,
          ),
        mediaDeleted => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE isDeleted IS NOT 0 ',
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
        mediaByNoteID => DBQuery<CLMedia>(
            sql:
                'SELECT Item.* FROM Item JOIN ItemNote ON Item.id = ItemNote.itemId WHERE ItemNote.noteId = ?;',
            triggerOnTables: const {'Item', 'Notes', 'ItemNote'},
            fromMap: CLMedia.fromMap,
          ),
        notesAll => DBQuery<CLNote>(
            sql: 'SELECT * FROM Notes',
            triggerOnTables: const {'Notes'},
            fromMap: CLNote.fromMap,
          ),
        noteById => DBQuery<CLNote>(
            sql: 'SELECT * FROM Notes WHERE id = ?;',
            triggerOnTables: const {'Notes'},
            fromMap: CLNote.fromMap,
          ),
        noteByPath => DBQuery<CLNote>(
            sql: 'SELECT * FROM Notes WHERE path = ?;',
            triggerOnTables: const {'Notes'},
            fromMap: CLNote.fromMap,
          ),
        notesByMediaId => DBQuery<CLNote>(
            sql:
                'SELECT Notes.* FROM Notes JOIN ItemNote ON Notes.id = ItemNote.noteId WHERE ItemNote.itemId = ?;',
            triggerOnTables: const {'Item', 'Notes', 'ItemNote'},
            fromMap: CLNote.fromMap,
          ),
        notesOrphan => DBQuery<CLNote>(
            sql:
                'SELECT n.* FROM Notes n LEFT JOIN ItemNote inote ON n.id = inote.noteId WHERE inote.noteId IS NULL',
            triggerOnTables: const {'Notes', 'ItemNote'},
            fromMap: CLNote.fromMap,
          ),
      };
}

const backupQuery = '''
SELECT 
    json_object(
        'itemId', Item.id,
        'itemPath', Item.path,
        'itemRef', Item.ref,
        'collectionLabel', Collection.label,
        'itemType', Item.type,
        'itemMd5String', Item.md5String,
        'itemOriginalDate', Item.originalDate,
        'itemCreatedDate', Item.createdDate,
        'itemUpdatedDate', Item.updatedDate,
         'notes',
        CASE 
            WHEN EXISTS (
                SELECT 1 
                FROM ItemNote 
                WHERE ItemNote.itemId = Item.id
            )
            THEN  json_group_array(
                    json_object(
                        'notePath', Notes.path,
                        'noteType', Notes.type
                    ))
                
           
        END 
    ) 
FROM 
    Item
LEFT JOIN 
    Collection ON Item.collectionId = Collection.id
LEFT JOIN 
    ItemNote ON Item.id = ItemNote.itemId
LEFT JOIN 
    Notes ON ItemNote.noteId = Notes.id
GROUP BY
    Item.id;
''';
