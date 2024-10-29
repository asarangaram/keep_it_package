import 'package:sqlite_async/sqlite_async.dart';

final migrations = SqliteMigrations()
  ..add(
    SqliteMigration(1, (tx) async {
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS Collection (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label TEXT NOT NULL UNIQUE,
        description TEXT,
        createdDate DATETIME NOT NULL,
        updatedDate DATETIME NOT NULL,
        isDeleted INTEGER NOT NULL,
        haveItOffline INTEGER NOT NULL DEFAULT 0,  -- relevant only if ServerUID is present
        serverUID INTEGER UNIQUE,  -- Nullable, to store serverUID if media is from another server
        isEdited INTEGER NOT NULL DEFAULT 0 -- relevant only if ServerUID is present
      )
    ''');
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS Media (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        md5String TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        fExt TEXT CHECK(length(fExt) BETWEEN 2 AND 6),
        ref TEXT,
        collectionId INTEGER,
        originalDate DATETIME,
        createdDate DATETIME,
        updatedDate DATETIME,
        isDeleted INTEGER NOT NULL,
        isHidden INTEGER NOT NULL,
        pin TEXT ,
        isAux INTEGER NOT NULL,
        
        -- User preferences
        haveItOffline INTEGER,  -- relevant only if ServerUID is present
        mustDownloadOriginal INTEGER NOT NULL DEFAULT 0,  -- relevant only if ServerUID is present

        -- local status
        isPreviewCached INTEGER NOT NULL DEFAULT 0,
        isMediaCached INTEGER NOT NULL DEFAULT 0,
        previewLog TEXT, -- Info stored as json
        mediaLog TEXT, -- Info stored as json
        isMediaOriginal INTEGER NOT NULL DEFAULT 0,
        serverUID INTEGER UNIQUE,  -- Nullable, to store serverUID if media is from another server
        isEdited INTEGER, -- relevant only if ServerUID is present

        FOREIGN KEY (collectionId) REFERENCES Collection(id)
      )
    ''');
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS MediaNote (
        noteId INTEGER,
        mediaId INTEGER,
        PRIMARY KEY (noteId, mediaId),
        FOREIGN KEY (noteId) REFERENCES Media(id) ON DELETE CASCADE,
        FOREIGN KEY (mediaId) REFERENCES Media(id) ON DELETE CASCADE
      )
    ''');
    }),
  );
