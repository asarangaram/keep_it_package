const backupQuery = '''
SELECT 
    json_object(
        'itemId', Media.id,
        'itemPath', Media.path,
        'itemRef', Media.ref,
        'collectionLabel', Collection.label,
        'itemType', Media.type,
        'itemMd5String', Media.md5String,
        'itemOriginalDate', Media.originalDate,
        'itemCreatedDate', Media.createdDate,
        'itemUpdatedDate', Media.updatedDate,
         'notes',
        CASE 
            WHEN EXISTS (
                SELECT 1 
                FROM MediaNote 
                WHERE MediaNote.itemId = Media.id
            )
            THEN  json_group_array(
                    json_object(
                        'notePath', Notes.path,
                        'noteType', Notes.type
                    ))
                
           
        END 
    ) 
FROM 
    Media
LEFT JOIN 
    Collection ON Media.collectionId = Collection.id
LEFT JOIN 
    MediaNote ON Media.id = MediaNote.itemId
LEFT JOIN 
    Notes ON MediaNote.noteId = Media.id
GROUP BY
    Media.id;
''';
