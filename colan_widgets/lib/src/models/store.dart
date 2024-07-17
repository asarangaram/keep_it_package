import 'cl_media.dart';
import 'cl_note.dart';
import 'collection.dart';

class StoreQuery<T> {
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
  Future<List<CLNote>?> getNotesByMediaID(int noteId);

  Future<void> reloadStore();

  Stream<List<T?>> storeReaderStream<T>(StoreQuery<T> storeQuery);
}
