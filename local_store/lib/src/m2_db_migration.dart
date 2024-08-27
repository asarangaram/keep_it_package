import 'package:sqlite_async/sqlite_async.dart';

final migrations = SqliteMigrations()
  ..add(
    SqliteMigration(1, (tx) async {
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS Collection (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label TEXT NOT NULL UNIQUE,
        description TEXT,
        createdDate DATETIME,
        updatedDate DATETIME
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
        FOREIGN KEY (collectionId) REFERENCES Collection(id)
      )
    ''');
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS MediaNote (
        noteId INTEGER,
        itemId INTEGER,
        PRIMARY KEY (noteId, itemId),
        FOREIGN KEY (noteId) REFERENCES Media(id) ON DELETE CASCADE,
        FOREIGN KEY (itemId) REFERENCES Media(id) ON DELETE CASCADE
      )
    ''');

      await tx.execute('''
      CREATE TABLE IF NOT EXISTS MediaLocalInfo (
        id INTEGER PRIMARY KEY,
        isPreviewCached INTEGER NOT NULL DEFAULT 0,
        isMediaCached INTEGER NOT NULL DEFAULT 0,
        previewError TEXT,
        mediaError TEXT,
        isMediaOriginal INTEGER NOT NULL DEFAULT 0,
        ServerUID INTEGER,  -- Nullable, to store ServerUID if media is from another server
        isEdited INTEGER NOT NULL DEFAULT 0, -- relevant only if ServerUID is present
        haveItOffline INTEGER NOT NULL DEFAULT 1,  -- relevant only if ServerUID is present
        mustDownloadOriginal INTEGER NOT NULL DEFAULT 0,  -- relevant only if ServerUID is present
        fileExtension STRING NOT NULL,
        FOREIGN KEY (id) REFERENCES Media(id) ON DELETE CASCADE
    );
  ''');
    }),
  );
