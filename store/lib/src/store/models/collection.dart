import 'package:colan_widgets/colan_widgets.dart';
import 'package:sqlite3/sqlite3.dart';

extension CollectionDB on Collection {
  static Collection getById(Database db, int id) {
    final map = db.select(
      'SELECT * FROM Collection WHERE id = ? ' 'ORDER BY LOWER(label) ASC',
      [id],
    ).first;
    return Collection.fromMap(map);
  }

  static List<Collection> getAll(Database db, {bool includeEmpty = true}) {
    final ResultSet maps;
    if (includeEmpty) {
      maps = db.select(
        'SELECT * FROM Collection ' 'ORDER BY LOWER(label) ASC',
      );
    } else {
      maps = db.select('SELECT DISTINCT Collection.* FROM Collection '
          'JOIN Item ON Collection.id = Item.collection_id;');
    }
    return maps.map(Collection.fromMap).toList();
  }

  static List<Collection> getByTagId(
    Database db,
    int id, {
    bool includeEmpty = false,
  }) {
    final ResultSet maps;
    if (includeEmpty) {
      maps = db.select(
        '''
        SELECT DISTINCT Collection.*
        FROM Collection
        JOIN TagCollection ON Collection.id = TagCollection.collection_id
        WHERE TagCollection.tag_id = :tagId;
    ''',
        [id],
      );
    } else {
      maps = db.select(
        '''
        SELECT DISTINCT Collection.*
        FROM Collection
        JOIN Item ON Collection.id = Item.collection_id
        JOIN TagCollection ON Collection.id = TagCollection.collection_id
        WHERE TagCollection.tag_id = :tagId;
    ''',
        [id],
      );
    }
    return maps.map(Collection.fromMap).toList();
  }

  static List<Collection> getUnused(
    Database db,
  ) {
    final ResultSet maps;

    maps = db.select('SELECT Collection.* FROM Collection '
        'LEFT JOIN Item ON Collection.id = Item.collection_id '
        'WHERE Item.collection_id IS NULL;');

    return maps.map(Collection.fromMap).toList();
  }

  Collection upsert(Database db) {
    if (id != null) {
      db.execute(
        'UPDATE Collection SET label = ? , description = ?  WHERE id = ?',
        [label, description, id],
      );
      return getById(db, id!);
    } else {
      db.execute(
        'INSERT INTO Collection (label, description) VALUES (?, ?) ',
        [label, description],
      );
      return getById(db, db.lastInsertRowId);
    }
  }

  void delete(Database db) {
    if (id == null) return;
    db
      ..execute(
        'DELETE FROM TagCollection WHERE collection_id = ?',
        [id],
      )
      ..execute(
        'DELETE FROM Collection WHERE id = ?',
        [id],
      )
      ..execute(
        'DELETE FROM Item WHERE collection_id = ?',
        [id],
      );
  }

  void addTag(
    Database db,
    int tagId,
  ) {
    if (id != null) {
      db.execute(
        'INSERT INTO TagCollection '
        '(tag_id, collection_id) VALUES (?, ?)',
        [tagId, id],
      );
    }
  }

  void removeTag(
    Database db,
    int tagId,
  ) {
    if (id != null) {
      db.execute(
        'INSERT OR IGNORE INTO TagCollection '
        'WHERE tag_id = ? , collection_id = ? ',
        [tagId, id],
      );
    }
  }

  bool isCollectionEmpty(
    Database db,
  ) {
    if (id != null) {
      final result = db.select(
        '''
    SELECT COUNT(*) as count
    FROM Item
    WHERE collection_id = ?
  ''',
        [id],
      );

      if (result.isNotEmpty) {
        final count = result.first['count'] as int;
        return count == 0;
      }
    }

    // Default to true if there's an issue with the query
    return true;
  }
  
}
