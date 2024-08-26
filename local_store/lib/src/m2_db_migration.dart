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
      CREATE TABLE IF NOT EXISTS ServerMediaMetaData (
        id INTEGER PRIMARY KEY,
        serverUID INTEGER NOT NULL UNIQUE,
        haveItOffline INTEGER NOT NULL CHECK(haveItOffline IN (0, 1)),
        mustDownloadOriginal INTEGER NOT NULL CHECK(mustDownloadOriginal IN (0, 1)),
        previewDownloaded INTEGER NOT NULL CHECK(previewDownloaded IN (0, 1)),
        mediaDownloaded INTEGER NOT NULL CHECK(mediaDownloaded IN (0, 1)),
        isMediaOriginal INTEGER NOT NULL CHECK(isMediaOriginal IN (0, 1)),
        locallyModified INTEGER NOT NULL CHECK(locallyModified IN (0, 1)),
        fileExtension TEXT CHECK(length(fileExtension) BETWEEN 2 AND 4),
        FOREIGN KEY (id) REFERENCES Media(id) ON DELETE CASCADE
    );
  ''');
    }),
  );
