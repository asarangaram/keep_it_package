import 'package:meta/meta.dart';

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
  mediaDownloadPending,
  previewDownloadPending,

  notesAll,
  notesByMediaId,
  notesOrphan,

  // Raw values
  serverUIDAll,
  mediaOnDevice,
  localMediaAll,
}

abstract class StoreQuery<T> {
  const StoreQuery();
}

abstract class StoreReader {
  Future<T?> read<T>(StoreQuery<T> query);

  Future<List<T?>> readMultiple<T>(StoreQuery<T> query);

  StoreQuery<T> getQuery<T>(DBQueries query, {List<Object?>? parameters});
  Future<Collection?> getCollectionByLabel(String label);
  Future<Collection?> getCollectionById(int id);

  Future<CLMedia?> getMediaByServerUID(int serverUID);
  Future<CLMedia?> getMediaByMD5String(String md5String);
  Future<CLMedia?> getMediaById(int id);
  Future<List<CLMedia>> getMediasByIDList(
    List<int> idList,
  );
  Future<List<CLMedia>> getMediaByCollectionId(
    int collectionId,
  );
  Future<List<CLMedia>> getNotesByMediaId(
    int mediaId,
  );
}

@immutable
abstract class Store {
  const Store(this.reader);
  final StoreReader reader;

  /// upsertCollection - introduce NULL return
  Future<Collection> upsertCollection(Collection collection);
  Future<CLMedia?> upsertMedia(CLMedia media, {List<CLMedia>? parents});
  //Future<CLMedia?> upsertNote(CLMedia note, List<CLMedia> mediaList);

  Future<CLMedia?> updateMediaFromMap(
    Map<String, dynamic> map,
  );

  Future<void> deleteCollection(Collection collection);
  Future<void> deleteMedia(CLMedia media);

  void reloadStore();

  Stream<List<T?>> storeReaderStream<T>(StoreQuery<T> storeQuery);

  void dispose();
}
