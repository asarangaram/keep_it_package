import 'package:sqlite3/sqlite3.dart';

import '../models/collection.dart';

extension CollectionDB on Collection {
  static Collection getById(Database db, int collectionId) {
    final Map<String, dynamic> map = db
        .select('SELECT * FROM Collection WHERE id = ?', [collectionId]).first;
    return Collection.fromMap(map);
  }

  static List<Collection> getAll(Database db) {
    final res = db.select('SELECT * FROM Collection');
    final collections = <Collection>[];
    for (final r in res) {
      collections.add(Collection.fromMap(r));
    }
    return collections;
  }

  int upsert(Database db) {
    if (id != null) {
      db.execute(
        'UPDATE Collection SET label = ? , description = ?  WHERE id = ?',
        [label, description, id],
      );
      return id!;
    } else {
      db.execute(
        'INSERT INTO Collection (label, description) VALUES (?, ?) ',
        [label, description],
      );
      return db.lastInsertRowId;
    }
  }

  void delete(Database db) {
    if (id == null) return;
    db
      ..execute('DELETE FROM Item WHERE collection_id = ?', [id])
      ..execute('DELETE FROM TagCollection WHERE collection_id = ?', [id])
      ..execute('DELETE FROM Collection WHERE id = ?', [id]);
  }

  static List<Collection> getCollectionsForTag(Database db, int tagId) {
    final List<Map<String, dynamic>> maps = db.select(
      '''
      SELECT Collection.* FROM Collection
      JOIN TagCollection ON Collection.id = TagCollection.collection_id
      WHERE TagCollection.tag_id = ?
    ''',
      [tagId],
    );
    return maps.map(Collection.fromMap).toList();
  }

  static void addTagToCollection(
    Database db,
    int tagId,
    int collectionId,
  ) {
    db.execute(
      'INSERT OR IGNORE INTO TagCollection '
      '(tag_id, collection_id) VALUES (?, ?)',
      [tagId, collectionId],
    );
  }
}
