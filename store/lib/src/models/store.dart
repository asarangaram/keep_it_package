import 'cl_media.dart';

import 'collection.dart';

enum DBQueries {
  // Fetch the complete table!
  collections,
  medias,

  collectionById,
  collectionByLabel,
  collectionsAll,
  collectionsExcludeEmpty,
  collectionsEmpty,
  collectionByIdList,

  mediaById,
  mediaByServerUID,
  mediaAll,
  mediaAllIncludingAux,
  mediaByCollectionId,
  mediaByPath,
  mediaByMD5,
  mediaPinned,
  mediaStaled,
  mediaDeleted,
  mediaByIdList,
  mediaByNoteID,

  notesAll,
  notesByMediaId,
  notesOrphan,
}

abstract class StoreQuery<T> {
  const StoreQuery();
}

abstract class Store {
  /// upsertCollection - introduce NULL return
  Future<Collection> upsertCollection(Collection collection);
  Future<CLMedia?> upsertMedia(CLMedia media, {List<CLMedia>? parents});
  //Future<CLMedia?> upsertNote(CLMedia note, List<CLMedia> mediaList);

  Future<void> deleteCollection(Collection collection);
  Future<void> deleteMedia(CLMedia media);

  Future<T?> read<T>(StoreQuery<T> query);

  Future<List<T?>> readMultiple<T>(StoreQuery<T> query);

  Future<void> reloadStore();

  Stream<List<T?>> storeReaderStream<T>(StoreQuery<T> storeQuery);
  StoreQuery<T> getQuery<T>(DBQueries query, {List<Object?>? parameters});

  void dispose();

  Future<Collection?> getCollectionByLabel(String label);
  Future<CLMedia?> getMediaByServerUID(int serverUID);
  Future<CLMedia?> getMediaByMD5String(String md5String);
}
