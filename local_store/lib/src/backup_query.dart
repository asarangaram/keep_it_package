const backupQuery = '''
SELECT 
    json_object(
        'mediaId', Media.id,
        'mediaName', Media.name,
        'mediaRef', Media.ref,
        'collectionLabel', Collection.label,
        'mediaType', Media.type,
        'mediaMd5String', Media.md5String,
        'mediaOriginalDate', Media.originalDate,
        'mediaCreatedDate', Media.createdDate,
        'mediaUpdatedDate', Media.updatedDate,
         'notes',
        CASE 
            WHEN EXISTS (
                SELECT 1 
                FROM MediaNote 
                WHERE MediaNote.MediaId = Media.id
            )
            THEN  json_group_array(
                    json_object(
                        'noteName', Notes.name,
                        'noteType', Notes.type
                    ))
                
           
        END 
    ) 
FROM 
    Media
LEFT JOIN 
    Collection ON Media.collectionId = Collection.id
LEFT JOIN 
    MediaNote ON Media.id = MediaNote.MediaId
LEFT JOIN 
    Notes ON MediaNote.noteId = Notes.id
GROUP BY
    Media.id;
''';
