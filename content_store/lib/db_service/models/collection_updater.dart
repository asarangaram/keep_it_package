import 'package:store/store.dart';

class CollectionUpdater {
  CollectionUpdater(this.store);
  Store store;

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
