import 'package:flutter/foundation.dart';
import 'package:store/store.dart';

class CollectionUpdater {
  CollectionUpdater(this.store);
  Store store;

  /// Method: upsert
  Future<CLEntity> upsert(
    CLEntity collection, {
    bool shouldRefresh = true,
  }) async {
    if (collection.id != null) {
      final c = await store.reader.getMediaById(collection.id!);
      if (collection == c) return collection;
    }

    final updated = await store.upsertMedia(collection);
    if (shouldRefresh) {
      store.reloadStore();
    }
    return updated!;
  }

  Future<CLEntity> update(
    CLEntity collection, {
    required bool isEdited,
    bool shouldRefresh = true,
    String? label,
    ValueGetter<String?>? description,
    DateTime? createdDate,
    DateTime? updatedDate,
    bool? haveItOffline,
    bool? isDeleted,
  }) {
    return upsert(
      collection.copyWith(
        label: () => label,
        description: description,
        addedDate: createdDate,
        updatedDate: updatedDate,
        isDeleted: isDeleted,
      ),
      shouldRefresh: shouldRefresh,
    );
  }

  /// Method: delete
  Future<bool> delete(
    int id, {
    bool shouldRefresh = true,
  }) async {
    final collection = await store.reader.getMediaById(id);
    if (collection != null) {
      final mediaMultiple = await store.reader.getMediaByCollectionId(id);

      for (final m in mediaMultiple) {
        await store.upsertMedia(
          m.updateContent(
            isDeleted: () => true,
          ),
        );
      }

      await update(collection, isEdited: true, isDeleted: true);

      if (shouldRefresh) {
        store.reloadStore();
      }
      return true;
    }
    return false;
  }

  /// Method: deletePermanently
  Future<bool> deletePermanently(
    int id, {
    bool shouldRefresh = true,
    Future<bool> Function(
      Set<int> ids2Delete, {
      bool shouldRefresh,
    })? onDeleteMedia,
  }) async {
    final collection = await store.reader.getMediaById(id);
    if (collection != null) {
      final medias = await store.reader.getMediaByCollectionId(id);
      if (medias.isNotEmpty) {
        if (onDeleteMedia != null) {
          await onDeleteMedia(
            medias.map((e) => e.id!).toSet(),
            shouldRefresh: shouldRefresh,
          );
        } else {
          throw Exception("can't delete a collection with media");
        }
      }
      await store.deleteMedia(collection);
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

  Future<CLEntity> getCollectionByLabel(
    String label, {
    DateTime? createdDate,
    DateTime? updatedDate,
    bool shouldRefresh = true,
    bool restoreIfNeeded = false,
  }) async {
    var collectionInDB = await store.reader.getCollectionByLabel(label);
    if (restoreIfNeeded && collectionInDB?.isDeleted != null) {
      collectionInDB = await upsert(collectionInDB!.copyWith(isDeleted: false));
    }
    final timeNow = DateTime.now();
    return collectionInDB ??
        await upsert(
          CLEntity.collection(
            id: null,
            label: label,
            addedDate: createdDate ?? timeNow,
            updatedDate: updatedDate ?? timeNow,
          ),
          shouldRefresh: shouldRefresh,
        );
  }
}
