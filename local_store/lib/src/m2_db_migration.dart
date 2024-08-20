import 'package:sqlite_async/sqlite_async.dart';

final migrations = SqliteMigrations()
  ..add(
    SqliteMigration(1, (tx) async {
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS Collection (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        label TEXT NOT NULL UNIQUE,
        createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedDate DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
      await tx.execute('''
      CREATE TRIGGER IF NOT EXISTS update_dates_on_collection
        AFTER UPDATE ON Collection
        BEGIN
            UPDATE Collection
            SET updatedDate = CURRENT_TIMESTAMP
            WHERE id = NEW.id;
        END;
    ''');
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS Item (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT NOT NULL UNIQUE,
        ref TEXT,
        collectionId INTEGER,
        type TEXT NOT NULL,
        md5String TEXT NOT NULL,
        originalDate DATETIME,
        createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (collectionId) REFERENCES Collection(id)
      )
    ''');
      await tx.execute('''
      CREATE TRIGGER IF NOT EXISTS update_dates_on_item
        AFTER UPDATE ON Item
        BEGIN
            UPDATE Item
            SET updatedDate = CURRENT_TIMESTAMP
            WHERE id = NEW.id;
        END;
    ''');
    }),
  )
  ..add(
    SqliteMigration(2, (tx) async {
      await tx.execute(
        'ALTER TABLE Item ADD COLUMN isDeleted INTEGER DEFAULT 0',
      );
      await tx.execute(
        'ALTER TABLE Item ADD COLUMN isHidden INTEGER DEFAULT 0',
      );
      await tx.execute(
        'ALTER TABLE Item ADD COLUMN isPinned INTEGER DEFAULT 0',
      );
      await tx.execute('UPDATE Item SET isDeleted = 0');
      await tx.execute('UPDATE Item SET isHidden = 0');
      await tx.execute('UPDATE Item SET isPinned = 0');
    }),
  )
  ..add(
    SqliteMigration(3, (tx) async {
      await tx.execute('ALTER TABLE Item ADD COLUMN pin TEXT DEFAULT NULL');
      await tx.execute('UPDATE Item SET pin = NULL');
    }),
  )
  ..add(
    SqliteMigration(4, (tx) async {
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS Notes (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT NOT NULL UNIQUE,
        type TEXT NOT NULL,
        createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedDate DATETIME DEFAULT CURRENT_TIMESTAMP
      )
      ''');
      await tx.execute('''
      CREATE TRIGGER IF NOT EXISTS update_dates_on_notes
        AFTER UPDATE ON Notes
        BEGIN
            UPDATE Notes
            SET updatedDate = CURRENT_TIMESTAMP
            WHERE id = NEW.id;
        END;
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
  )
  ..add(
    SqliteMigration(5, (tx) async {
      await tx.execute(
        'ALTER TABLE Collection ADD COLUMN locallyModified INTEGER DEFAULT 1',
      );
      await tx.execute(
        'ALTER TABLE Item ADD COLUMN locallyModified INTEGER DEFAULT 1',
      );
      await tx.execute(
        'ALTER TABLE Notes ADD COLUMN locallyModified INTEGER DEFAULT 1',
      );

      await tx.execute(
        'ALTER TABLE Collection ADD COLUMN serverUID INTEGER ',
      );
      await tx.execute(
        'ALTER TABLE Item ADD COLUMN serverUID INTEGER ',
      );
      await tx.execute(
        'ALTER TABLE Notes ADD COLUMN serverUID INTEGER ',
      );

      await tx.execute('UPDATE Collection SET locallyModified = 1');
      await tx.execute('UPDATE Item SET locallyModified = 1');
      await tx.execute('UPDATE Notes SET locallyModified = 1');

      await tx.execute('UPDATE Collection SET serverUID = NULL');
      await tx.execute('UPDATE Item SET serverUID = NULL');
      await tx.execute('UPDATE Notes SET serverUID = NULL');
    }),
  )
  ..add(
    SqliteMigration(6, (tx) async {
      await tx.execute(
        'CREATE UNIQUE INDEX idx_collection_serverUID ON Collection(serverUID)',
      );

      await tx.execute(
        'CREATE UNIQUE INDEX idx_item_serverUID ON Item(serverUID)',
      );

      await tx.execute(
        'CREATE UNIQUE INDEX idx_notes_serverUID ON Notes(serverUID)',
      );
    }),
  )
  ..add(
    SqliteMigration(7, (tx) async {
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS Server (
        UUID TEXT NOT NULL UNIQUE,
        INFO TEXT 
      )
      ''');
    }),
  );
