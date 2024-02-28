import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:signals/signals_flutter.dart';
import 'package:sqlite_async/sqlite_async.dart';
import 'package:store/src/store_signals/db_extension.dart';

import 'subscriptions.dart';

class DBManager {
  DBManager(Directory docDir) {
    if (File(join(docDir.path, 'keepIt.db')).existsSync()) {
      File(join(docDir.path, 'keepIt.db'))
          .copySync(join(docDir.path, 'keepIt2.db'));
    }
    db = SqliteDatabase(path: join(docDir.path, 'keepIt2.db'));
  }
  late final SqliteDatabase db;
  final List<Subscribed<dynamic>> subscriptions = [];
  ListSignal<T> subscribe<T>(Subscription<T> subscription) {
    final existing =
        subscriptions.where((e) => e.subscription == subscription).firstOrNull;
    if (existing != null) {
      return existing.subscription.signal as ListSignal<T>;
    }

    final newSubscription = Subscribed(
      subscription,
      db
          .watchRows(
            subscription.query,
            triggerOnTables: subscription.watchTables,
          )
          .map(
            (rows) => rows.map((e) => subscription.fromMap(e)).toList(),
          )
          .listen((event) => subscription.signal.value = event),
    );

    subscriptions.add(
      newSubscription,
    );
    return newSubscription.subscription.signal as ListSignal<T>;
  }

  void unsubscribe(String label) {}

  void dispose() {
    for (final entry in subscriptions) {
      entry.stream.cancel();
    }
    db.close();
  }
}

final migrations = SqliteMigrations()
  ..add(
    SqliteMigration(1, (tx) async {
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS Tag (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        label TEXT NOT NULL UNIQUE,
        description TEXT,
        createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedDate DATETIME DEFAULT CURRENT_TIMESTAMP
      )
    ''');
      await tx.execute('''
      CREATE TRIGGER IF NOT EXISTS update_dates_on_tag
        AFTER UPDATE ON Tag
        BEGIN
            UPDATE Tag
            SET updatedDate = CURRENT_TIMESTAMP
            WHERE id = NEW.id;
        END;
    ''');
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
        collection_id INTEGER,
        type TEXT NOT NULL,
        md5String TEXT NOT NULL,
        originalDate DATETIME,
        createdDate DATETIME DEFAULT CURRENT_TIMESTAMP,
        updatedDate DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (collection_id) REFERENCES Collection(id)
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
      await tx.execute('''
      CREATE TABLE IF NOT EXISTS TagCollection (
        tag_id INTEGER,
        collection_id INTEGER,
        FOREIGN KEY (tag_id) REFERENCES Tag(id),
        FOREIGN KEY (collection_id) REFERENCES Collection(id),
        PRIMARY KEY (tag_id, collection_id)
      )
    ''');
    }),
  );

class Store extends DBManager {
  Store(super.docDir);

  static Future<Store> create() async {
    final docDir = await getApplicationDocumentsDirectory();
    _store ??= Store(docDir);
    await migrations.migrate(_store!.db);

    return _store!;
  }

  static Store get store {
    if (_store == null) {
      throw Exception('Store has not been created');
    }
    return _store!;
  }
}

Store? _store;
