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
        
      )
    ''');
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS Media (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL ,
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
        mediaId INTEGER,
        PRIMARY KEY (noteId, mediaId),
        FOREIGN KEY (noteId) REFERENCES Media(id) ON DELETE CASCADE,
        FOREIGN KEY (mediaId) REFERENCES Media(id) ON DELETE CASCADE
      )
    ''');
    }),
  );
