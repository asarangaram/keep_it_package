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
        updatedDate DATETIME,
        locallyModified INTEGER NOT NULL,
        serverUID INTEGER
      )
    ''');
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS Media (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE,
        md5String TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        ref TEXT,
        collectionId INTEGER,
        originalDate DATETIME,
        createdDate DATETIME,
        updatedDate DATETIME,
        isDeleted INTEGER NOT NULL,
        isHidden INTEGER NOT NULL,
        pin TEXT ,
        locallyModified INTEGER NOT NULL,
        serverUID INTEGER,
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
      CREATE TABLE IF NOT EXISTS Server (
        UUID TEXT NOT NULL UNIQUE,
        INFO TEXT 
      )
    ''');
    }),
  )
  ..add(
    SqliteMigration(2, (tx) async {
      // Add new columns
      await tx.execute('''
      ALTER TABLE Media ADD COLUMN haveItOffline INTEGER NOT NULL DEFAULT 1
    ''');
      await tx.execute('''
      ALTER TABLE Media ADD COLUMN mustDownloadOriginal INTEGER NOT NULL DEFAULT 0
    ''');
      await tx.execute('''
      ALTER TABLE Media ADD COLUMN downloadStatus TEXT
    ''');

      // Set default values for existing rows
      await tx.execute('''
      UPDATE Media
      SET haveItOffline = 1,
          mustDownloadOriginal = 0
    ''');
    }),
  );
