import 'package:sqlite_async/sqlite_async.dart';

final migrations = SqliteMigrations()
  ..add(
    SqliteMigration(1, (tx) async {
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS Collection (
          id INTEGER NOT NULL PRIMARY KEY,  -- Not auto-incremented
          label TEXT NOT NULL UNIQUE,
          createdDate DATETIME NOT NULL,
          updatedDate DATETIME NOT NULL,
          description TEXT,
          isDirty INTEGER DEFAULT TRUE
      );
    ''');
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS Item (
        id INTEGER NOT NULL UNIQUE,
        path TEXT NOT NULL UNIQUE,
        ref TEXT,
        collectionId INTEGER,
        type TEXT NOT NULL,
        md5String TEXT NOT NULL,
        originalDate DATETIME,
        createdDate DATETIME NOT NULL,
        updatedDate DATETIME NOT NULL,
        isDeleted INTEGER DEFAULT 0,
        isHidden INTEGER DEFAULT 0,
        pin TEXT DEFAULT NULL,
        isDirty INTEGER DEFAULT TRUE,
        FOREIGN KEY (collectionId) REFERENCES Collection(id)
      )
    ''');
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS Notes (
        id INTEGER NOT NULL UNIQUE,
        path TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        createdDate DATETIME NOT NULL,
        updatedDate DATETIME NOT NULL,
        isDirty INTEGER DEFAULT TRUE
      )
      ''');
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS ItemNote (
        noteId INTEGER,
        itemId INTEGER,
        PRIMARY KEY (noteId, itemId),
        FOREIGN KEY (noteId) REFERENCES Notes(id) ON DELETE CASCADE,
        FOREIGN KEY (itemId) REFERENCES Item(id) ON DELETE CASCADE
      )
      ''');
    }),
  );
