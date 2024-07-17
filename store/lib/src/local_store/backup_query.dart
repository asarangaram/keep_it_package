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
