import 'package:colan_widgets/colan_widgets.dart';
import 'package:sqlite_async/sqlite_async.dart';


extension CollectionDB on Collection {
  /* static List<Collection> getUnused(
    Database db,
  ) {
    final ResultSet maps;

    maps = db.select('SELECT Collection.* FROM Collection '
        'LEFT JOIN Item ON Collection.id = Item.collection_id '
        'WHERE Item.collection_id IS NULL;');

    return maps.map(Collection.fromMap).toList();
  } */

  Collection upsert(SqliteDatabase db) {
    /* if (id != null) {
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
    } */
    return const Collection(label: 'unexpected');
  }

  void delete(SqliteDatabase db) {
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
    SqliteDatabase db,
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
    SqliteDatabase db,
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

  /* void addTags(SqliteDatabase db, List<Tag>? tagsToAdd) {
    if (tagsToAdd != null) {
      for (final tag in tagsToAdd) {
        tag.upsert(db);
        addTag(db, tag.id!);
      }
    }
  }

  void removeTags(SqliteDatabase db, List<Tag>? tagsToRemove) {
    if (tagsToRemove != null) {
      for (final tag in tagsToRemove) {
        removeTag(db, tag.id!);
      }
    }
  } */

  /* bool isCollectionEmpty(
    SqliteDatabase db,
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
  } */

  /* void addMediaDB(
    List<CLMedia> media, {
    required String pathPrefix,
    required SqliteDatabase db,
  }) {
    for (final item in media) {
      item.upsert(db, pathPrefix: pathPrefix, collectionPath: path);
    }
  } */

  /* (List<Tag>?, List<Tag>?) splitTags(
    SqliteDatabase db,
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
  } */
}
