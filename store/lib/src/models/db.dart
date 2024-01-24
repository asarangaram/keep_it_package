import 'package:sqlite3/sqlite3.dart';

export '../extensions/cluster.dart';
export '../extensions/collections.dart';
export '../extensions/item.dart';

class DatabaseManager {
  DatabaseManager({String? path, void Function()? sqlite3LibOverrider}) {
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
      CREATE TABLE IF NOT EXISTS Collection (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label TEXT NOT NULL UNIQUE,
        description TEXT,
        CREATED_DATE DATETIME DEFAULT CURRENT_TIMESTAMP,
        UPDATED_DATE DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''')
      ..execute('''
      CREATE TRIGGER IF NOT EXISTS update_dates_on_collection
        AFTER UPDATE ON Collection
        BEGIN
            UPDATE Collection
            SET UPDATED_DATE = CURRENT_TIMESTAMP
            WHERE id = NEW.id;
        END;
    ''')
      ..execute('''
      CREATE TABLE IF NOT EXISTS Cluster (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        text TEXT
        CREATED_DATE DATETIME DEFAULT CURRENT_TIMESTAMP,
        UPDATED_DATE DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''')
      ..execute('''
      CREATE TRIGGER IF NOT EXISTS update_dates_on_cluster
        AFTER UPDATE ON Cluster
        BEGIN
            UPDATE Collection
            SET UPDATED_DATE = CURRENT_TIMESTAMP
            WHERE id = NEW.id;
        END;
    ''')
      ..execute('''
      CREATE TABLE IF NOT EXISTS Item (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT NOT NULL UNIQUE,
        ref TEXT,
        cluster_id INTEGER,
        type TEXT NOT NULL,
         CREATED_DATE DATETIME DEFAULT CURRENT_TIMESTAMP,
        UPDATED_DATE DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (cluster_id) REFERENCES Cluster(id)
      )
    ''')
      ..execute('''
      CREATE TRIGGER IF NOT EXISTS update_dates_on_item
        AFTER UPDATE ON Cluster
        BEGIN
            UPDATE Collection
            SET UPDATED_DATE = CURRENT_TIMESTAMP
            WHERE id = NEW.id;
        END;
    ''')
      ..execute('''
      CREATE TABLE IF NOT EXISTS CollectionCluster (
        collection_id INTEGER,
        cluster_id INTEGER,
        FOREIGN KEY (collection_id) REFERENCES Collection(id),
        FOREIGN KEY (cluster_id) REFERENCES Cluster(id),
        PRIMARY KEY (collection_id, cluster_id)
      )
    ''');
  }

  // Close the database connection
  void close() {
    db.dispose();
  }
}
