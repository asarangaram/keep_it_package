// ignore_for_file: lines_longer_than_80_chars

import 'package:colan_widgets/colan_widgets.dart';
import 'package:device_resources/device_resources.dart';

import 'm3_db_query.dart';
import 'map_fixer.dart';

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
            fromMap: NullablesFromMap.collection,
          ),
        collectionByLabel => DBQuery<Collection>(
            sql: 'SELECT * FROM Collection WHERE label = ? ',
            triggerOnTables: const {'Collection'},
            fromMap: NullablesFromMap.collection,
          ),
        collectionsAll => DBQuery<Collection>(
            sql: 'SELECT * FROM Collection '
                "WHERE label NOT LIKE '***%'",
            triggerOnTables: const {'Collection'},
            fromMap: NullablesFromMap.collection,
          ),
        collectionsExcludeEmpty => DBQuery<Collection>(
            sql: 'SELECT DISTINCT Collection.* FROM Collection '
                'JOIN Item ON Collection.id = Item.collectionId '
                "WHERE label NOT LIKE '***%' AND "
                'Item.isDeleted = 0',
            triggerOnTables: const {'Collection', 'Item'},
            fromMap: NullablesFromMap.collection,
          ),
        collectionsEmpty => DBQuery<Collection>(
            sql: 'SELECT Collection.* FROM Collection '
                'LEFT JOIN Item ON Collection.id = Item.collectionId '
                'WHERE Item.collectionId IS NULL AND '
                "label NOT LIKE '***%' AND "
                'Item.isDeleted = 0',
            triggerOnTables: const {'Collection', 'Item'},
            fromMap: NullablesFromMap.collection,
          ),
        mediaById => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE id = ?',
            triggerOnTables: const {'Item'},
            fromMap: NullablesFromMap.media,
          ),
        mediaAll => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE isHidden IS 0 AND isDeleted IS 0',
            triggerOnTables: const {'Item'},
            fromMap: NullablesFromMap.media,
          ),
        mediaByCollectionId => DBQuery<CLMedia>(
            sql:
                'SELECT * FROM Item WHERE collectionId = ? AND isHidden IS 0 AND isDeleted IS 0',
            triggerOnTables: const {'Item'},
            fromMap: NullablesFromMap.media,
          ),
        mediaByMD5 => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE md5String = ?',
            triggerOnTables: const {'Item'},
            fromMap: NullablesFromMap.media,
          ),
        mediaPinned => DBQuery<CLMedia>(
            sql:
                "SELECT * FROM Item WHERE NULLIF(pin, 'null') IS NOT NULL AND isHidden IS 0 AND isDeleted IS 0",
            triggerOnTables: const {'Item'},
            fromMap: NullablesFromMap.media,
          ),
        mediaStaled => DBQuery<CLMedia>(
            sql:
                'SELECT * FROM Item WHERE isHidden IS NOT 0 AND isDeleted IS 0',
            triggerOnTables: const {'Item'},
            fromMap: NullablesFromMap.media,
          ),
        mediaDeleted => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE isDeleted IS NOT 0 ',
            triggerOnTables: const {'Item'},
            fromMap: NullablesFromMap.media,
          ),
        mediaByPath => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE path = ?',
            triggerOnTables: const {'Item'},
            fromMap: NullablesFromMap.media,
          ),
        mediaByIdList => DBQuery<CLMedia>(
            sql: 'SELECT * FROM Item WHERE id IN (?)',
            triggerOnTables: const {'Item'},
            fromMap: NullablesFromMap.media,
          ),
        mediaByNoteID => DBQuery<CLMedia>(
            sql:
                'SELECT Item.* FROM Item JOIN ItemNote ON Item.id = ItemNote.itemId WHERE ItemNote.noteId = ?;',
            triggerOnTables: const {'Item', 'Notes', 'ItemNote'},
            fromMap: NullablesFromMap.media,
          ),
        notesAll => DBQuery<CLNote>(
            sql: 'SELECT * FROM Notes',
            triggerOnTables: const {'Notes'},
            fromMap: NullablesFromMap.note,
          ),
        noteById => DBQuery<CLNote>(
            sql: 'SELECT * FROM Notes WHERE id = ?;',
            triggerOnTables: const {'Notes'},
            fromMap: NullablesFromMap.note,
          ),
        noteByPath => DBQuery<CLNote>(
            sql: 'SELECT * FROM Notes WHERE path = ?;',
            triggerOnTables: const {'Notes'},
            fromMap: NullablesFromMap.note,
          ),
        notesByMediaId => DBQuery<CLNote>(
            sql:
                'SELECT Notes.* FROM Notes JOIN ItemNote ON Notes.id = ItemNote.noteId WHERE ItemNote.itemId = ?;',
            triggerOnTables: const {'Item', 'Notes', 'ItemNote'},
            fromMap: NullablesFromMap.note,
          ),
        notesOrphan => DBQuery<CLNote>(
            sql:
                'SELECT n.* FROM Notes n LEFT JOIN ItemNote inote ON n.id = inote.noteId WHERE inote.noteId IS NULL',
            triggerOnTables: const {'Notes', 'ItemNote'},
            fromMap: NullablesFromMap.note,
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

class NullablesFromMap {
  static Collection? collection(
    Map<String, dynamic> map, {
    required AppSettings appSettings,
  }) {
    return Collection.fromMap(map);
  }

  static MapFixer incomingMapFixer(String basePath) => MapFixer(
        pathType: PathType.absolute,
        basePath: basePath,
        mandatoryKeys: const ['type', 'path', 'md5String'],
        pathKeys: const ['path'],
        removeValues: const ['null'],
      );

  static CLMedia? media(
    Map<String, dynamic> map1, {
    required AppSettings appSettings,
  }) {
    final map = incomingMapFixer(appSettings.directories.media.pathString).fix(
      map1,
      /* onError: (errors) {
        if (errors.isNotEmpty) {
          logger.e(errors.join(','));
          return false;
        }
        return true;
      }, */
    );
    if (map.isEmpty) {
      return null;
    }
    return CLMedia.fromMap(map);
  }

  static CLNote? note(
    Map<String, dynamic> map1, {
    // ignore: avoid_unused_constructor_parameters
    required AppSettings appSettings,
  }) {
    final map = incomingMapFixer(appSettings.directories.notes.pathString).fix(
      map1,
      /* onError: (errors) {
          if (errors.isNotEmpty) {
            logger.e(errors.join(','));
            return false;
          }
          return true;
        }, */
    );
    if (map.isEmpty) {
      return null;
    }
    return CLNote.fromMap(map);
  }
}
