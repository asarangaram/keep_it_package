import 'package:store/src/models/media_local_info.dart';

import 'cl_media.dart';

import 'collection.dart';

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

  localInfoById,
  localInfoByServerUID,
  localInfoAll,

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
  Future<MediaLocalInfo> upsertServerInfo(
    MediaLocalInfo mediaServerInfo,
  );

  Future<void> deleteCollection(Collection collection);
  Future<void> deleteMedia(CLMedia media, {required bool permanent});
  Future<void> deleteNote(CLMedia note);
  Future<void> deleteServerInfo(MediaLocalInfo mediaServerInfo);

  Future<List<Object?>?> getDBRecords();

  Future<T?> read<T>(StoreQuery<T> query);

  Future<List<T?>> readMultiple<T>(StoreQuery<T> query);

  Future<void> reloadStore();

  Stream<List<T?>> storeReaderStream<T>(StoreQuery<T> storeQuery);
  StoreQuery<T> getQuery<T>(DBQueries query, {List<Object?>? parameters});

  void dispose();
}
