import 'cl_media.dart';
import 'cl_server.dart';
import 'collection.dart';
import 'server_media_info.dart';

enum DBQueries {
  collectionById,
  collectionByLabel,
  collectionsAll,
  collectionsExcludeEmpty,
  collectionsEmpty,
  collectionByIdList,

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

  mediaServerInfoById,
  mediaServerInfoByServerUID,
  mediaServerInfoAll,

  notesAll,
  notesByMediaId,
  notesOrphan,
  collectionLocallyModified,
  mediaLocallyModified,
}

abstract class StoreQuery<T> {
  const StoreQuery();
}

abstract class Store {
  /// upsertCollection - introduce NULL return
  Future<Collection> upsertCollection(Collection collection);
  Future<CLMedia?> upsertMedia(CLMedia media);
  Future<CLMedia?> upsertNote(CLMedia note, List<CLMedia> mediaList);
  Future<MediaServerInfo> upsertServerInfo(MediaServerInfo mediaServerInfo);

  Future<void> deleteCollection(Collection collection);
  Future<void> deleteMedia(CLMedia media, {required bool permanent});
  Future<void> deleteNote(CLMedia note);
  Future<void> deleteServerInfo(MediaServerInfo mediaServerInfo);

  Future<List<Object?>?> getDBRecords();

  Future<T?> read<T>(StoreQuery<T> query);

  Future<List<T?>> readMultiple<T>(StoreQuery<T> query);

  Future<void> reloadStore();

  Stream<List<T?>> storeReaderStream<T>(StoreQuery<T> storeQuery);
  StoreQuery<T> getQuery<T>(DBQueries query, {List<Object?>? parameters});

  void dispose();

  Future<Store> attachServer(CLServer? value);
}
