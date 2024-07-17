import 'cl_media.dart';
import 'cl_note.dart';
import 'collection.dart';

enum DBQueries {
  collectionById,
  collectionByLabel,
  collectionsAll,
  collectionsExcludeEmpty,
  collectionsEmpty,

  mediaById,
  mediaAll,
  mediaByCollectionId,
  mediaByPath,
  mediaByMD5,
  mediaPinned,
  mediaStaled,
  mediaDeleted,
  mediaByIdList,
  mediaByNoteID,
  notesAll,
  noteById,
  noteByPath,
  notesByMediaId,
  notesOrphan;
}

abstract class StoreQuery<T> {
  const StoreQuery();
}

abstract class Store {
  /// upsertCollection - introduce NULL return
  Future<Collection> upsertCollection(Collection collection);
  Future<CLMedia?> upsertMedia(CLMedia media);
  Future<CLNote?> upsertNote(CLNote note, List<CLMedia> mediaList);

  Future<void> deleteCollection(Collection collection);
  Future<void> deleteMedia(CLMedia media, {required bool permanent});
  Future<void> deleteNote(CLNote note);

  Future<List<Object?>?> getDBRecords();

  Future<Collection?> getCollectionByLabel(String label);
  Future<CLMedia?> getMediaByMD5(String md5String);
  Future<List<CLNote>?> getNotesByMediaID(int mediaId);

  Future<void> reloadStore();

  Stream<List<T?>> storeReaderStream<T>(StoreQuery<T> storeQuery);
  StoreQuery<Object> getQuery(DBQueries query, {List<Object?>? parameters});

  void dispose();
}
