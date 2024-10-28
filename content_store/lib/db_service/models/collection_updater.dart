import 'package:store/store.dart';

class CollectionUpdater {
  CollectionUpdater(this.store);
  Store store;

  /// Method: upsert
  Future<Collection> upsert(
    Collection collection, {
    bool shouldRefresh = true,
  }) async {
    if (collection.id != null) {
      final c = await store.reader.getCollectionById(collection.id!);
      if (collection == c) return collection;
    }

    final updated = store.upsertCollection(collection);
    if (shouldRefresh) {
      store.reloadStore();
    }
    return updated;
  }

  /// Method: delete
  Future<bool> delete(
    int id, {
    bool shouldRefresh = true,
  }) async {
    final mediaMultiple = await store.reader.getMediaByCollectionId(id);

    for (final m in mediaMultiple) {
      await store.upsertMedia(
        m.updateContent(
          isDeleted: () => true,
          isEdited: true,
        ),
      );
    }

    if (shouldRefresh) {
      store.reloadStore();
    }
    return true;
  }

  /// Method: deletePermanently
  Future<bool> deletePermanently(
    int id, {
    bool shouldRefresh = true,
  }) async {
    final collection = await store.reader.getCollectionById(id);
    if (collection != null) {
      final medias = await store.reader.getMediaByCollectionId(id);
      if (medias.isNotEmpty) {
        throw Exception("can't delete a collection with media");
      }
      await store.deleteCollection(collection);
      return true;
    }
    return false;
  }

  /// Method: deleteMultiple
  Future<bool> deleteMultiple(
    Set<int> ids2Delete, {
    bool shouldRefresh = true,
  }) async {
    throw UnimplementedError();
  }

  // Method: restore
  Future<bool> restoreMultiple(
    int id, {
    bool shouldRefresh = true,
  }) async {
    throw UnimplementedError();
  }

  // Method: restoreMultiple
  Future<bool> restore(
    int id, {
    bool shouldRefresh = true,
  }) async {
    throw UnimplementedError();
  }

  Future<Collection> getCollectionByLabel(
    String label, {
    DateTime? createdDate,
    DateTime? updatedDate,
    int? serverUID,
    bool shouldRefresh = true,
  }) async {
    return (await store.reader.getCollectionByLabel(label)) ??
        await upsert(
          Collection.byLabel(
            label,
            createdDate: createdDate,
            updatedDate: updatedDate,
            serverUID: serverUID,
          ),
          shouldRefresh: shouldRefresh,
        );
  }
}
