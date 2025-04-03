import 'package:sqlite_async/sqlite_async.dart';

final migrations = SqliteMigrations()
  ..add(
    SqliteMigration(1, (tx) async {
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS Entity (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        isCollection INTEGER NOT NULL,
        addedDate DATETIME NOT NULL,
        updatedDate DATETIME NOT NULL,
        isDeleted INTEGER NOT NULL,

        label TEXT ,
        description TEXT,
        parentId INTEGER,

        
        md5 TEXT UNIQUE,
        fileSize INTEGER,
        mimeType TEXT,
        type TEXT,
        extension TEXT CHECK(length(fExt) BETWEEN 2 AND 6),

        createDate DATETIME,
        height INTEGER,
        width INTEGER,
        duration REAL,
        
        isHidden INTEGER NOT NULL,
        pin TEXT,
        FOREIGN KEY (parentId) REFERENCES Entity(id)
      )

      -- Constraints
        CHECK ( 
          (isCollection = 1 AND label IS NOT NULL AND label != '') OR 
          (isCollection = 0 AND md5 IS NOT NULL AND fileSize IS NOT NULL AND
          mimeType IS NOT NULL AND type IS NOT NULL AND extension IS NOT NULL)
        ),
        CHECK (
        pin IS NOT NULL AND isDeleted IS NOT NULL AND isHidden IS NOT NULL
        ),
        UNIQUE(label) WHERE isCollection = 1
        UNIQUE(md5) WHERE isCollection = 0
        
    ''');
    }),
  );
