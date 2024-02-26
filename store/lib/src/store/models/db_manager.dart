import 'package:sqlite3/sqlite3.dart';

class DBManager {
  DBManager({String? path, void Function()? sqlite3LibOverrider}) {
    sqlite3LibOverrider?.call();
    db = switch (path) {
      null => sqlite3.openInMemory(),
      _ => sqlite3.open(path)
    };

    _createTables();
  }
  late Database db;

  void _createTables() {
    db
      ..execute('''
      CREATE TABLE IF NOT EXISTS Tag (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label TEXT NOT NULL UNIQUE,
        description TEXT,
        createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedDate DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''')
      ..execute('''
      CREATE TRIGGER IF NOT EXISTS update_dates_on_tag
        AFTER UPDATE ON Tag
        BEGIN
            UPDATE Tag
            SET updatedDate = CURRENT_TIMESTAMP
            WHERE id = NEW.id;
        END;
    ''')
      ..execute('''
      CREATE TABLE IF NOT EXISTS Collection (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        label TEXT NOT NULL UNIQUE,
        createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedDate DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''')
      ..execute('''
      CREATE TRIGGER IF NOT EXISTS update_dates_on_collection
        AFTER UPDATE ON Collection
        BEGIN
            UPDATE Collection
            SET updatedDate = CURRENT_TIMESTAMP
            WHERE id = NEW.id;
        END;
    ''')
      ..execute('''
      CREATE TABLE IF NOT EXISTS Item (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT NOT NULL UNIQUE,
        ref TEXT,
        collection_id INTEGER,
        type TEXT NOT NULL,
        md5String TEXT NOT NULL,
        originalDate DATETIME,
        createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (collection_id) REFERENCES Collection(id)
      )
    ''')
      ..execute('''
      CREATE TRIGGER IF NOT EXISTS update_dates_on_item
        AFTER UPDATE ON Item
        BEGIN
            UPDATE Item
            SET updatedDate = CURRENT_TIMESTAMP
            WHERE id = NEW.id;
        END;
    ''')
      ..execute('''
      CREATE TABLE IF NOT EXISTS TagCollection (
        tag_id INTEGER,
        collection_id INTEGER,
        FOREIGN KEY (tag_id) REFERENCES Tag(id),
        FOREIGN KEY (collection_id) REFERENCES Collection(id),
        PRIMARY KEY (tag_id, collection_id)
      )
    ''');
  }

  // Close the database connection
  void close() {
    db.dispose();
  }
}
