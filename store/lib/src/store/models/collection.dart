import 'package:colan_widgets/colan_widgets.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:store/src/store/models/cl_media.dart';
import 'package:store/src/store/models/tag.dart';

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
    bool includeEmpty = true,
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
        [label.trim(), description?.trim(), id],
      );
      return getById(db, id!);
    } else {
      db.execute(
        'INSERT INTO Collection (label, description) VALUES (?, ?) ',
        [label.trim(), description?.trim()],
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
        'DELETE FROM TagCollection '
        'WHERE tag_id = ? AND collection_id = ? ',
        [tagId, id],
      );
    }
  }

  void addTags(Database db, List<Tag>? tagsToAdd) {
    if (tagsToAdd != null) {
      for (final tag in tagsToAdd) {
        tag.upsert(db);
        addTag(db, tag.id!);
      }
    }
  }

  void removeTags(Database db, List<Tag>? tagsToRemove) {
    if (tagsToRemove != null) {
      for (final tag in tagsToRemove) {
        removeTag(db, tag.id!);
      }
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

  void addMediaDB(
    List<CLMedia> media, {
    required String pathPrefix,
    required Database db,
  }) {
    for (final item in media) {
      item.upsert(db, pathPrefix: pathPrefix, collectionPath: path);
    }
  }

  (List<Tag>?, List<Tag>?) splitTags(
    Database db,
    List<Tag>? tags,
  ) {
    List<Tag>? tagsToAdd;
    List<Tag>? tagsToRemove;
    if (tags == null) return (null, null);
    if (id == null) return (tags, null);

    final existingTags = TagDB.getByCollectionId(db, id!);
    tagsToAdd = tags
        .where(
          (updatedTag) => !existingTags
              .any((existingTag) => existingTag.id == updatedTag.id),
        )
        .toList();

    tagsToRemove = existingTags
        .where(
          (existingTag) =>
              !tags.any((updatedTag) => updatedTag.id == existingTag.id),
        )
        .toList();
    return (tagsToAdd, tagsToRemove);
  }

  void replaceTags(Database db, List<Tag>? tags) {
    if (tags == null) {
      return;
    }
    final (tagsToAdd, tagsToRemove) = splitTags(db, tags);

    addTags(db, tagsToAdd);
    removeTags(db, tagsToRemove);
  }
}
