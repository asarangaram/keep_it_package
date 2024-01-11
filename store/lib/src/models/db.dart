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
      CREATE TABLE IF NOT EXISTS Collections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label TEXT NOT NULL UNIQUE,
        description TEXT
      )
    ''')
      ..execute('''
      CREATE TABLE IF NOT EXISTS Cluster (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        description TEXT,
        text TEXT
      )
    ''')
      ..execute('''
      CREATE TABLE IF NOT EXISTS Item (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        path TEXT NOT NULL UNIQUE,
        ref TEXT,
        cluster_id INTEGER,
        type TEXT NOT NULL,
        FOREIGN KEY (cluster_id) REFERENCES Cluster(id)
      )
    ''')
      ..execute('''
      CREATE TABLE IF NOT EXISTS CollectionCluster (
        collection_id INTEGER,
        cluster_id INTEGER,
        FOREIGN KEY (collection_id) REFERENCES Collections(id),
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
