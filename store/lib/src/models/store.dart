import 'package:meta/meta.dart';

import '../extensions/ext_list.dart';
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
  collectionOnDevice,
  localMediaAll,
}

abstract class StoreQuery<T> {
  const StoreQuery();
}

abstract class StoreReader {
  Future<T?> read<T>(StoreQuery<T> query);
  Future<List<T?>> readMultiple<T>(StoreQuery<T> query);
  StoreQuery<T> getQuery<T>(DBQueries query, {List<Object?>? parameters});

  Future<T?> get<T>(DBQueries query, {List<Object?>? parameters}) async {
    final q = getQuery(DBQueries.collectionById, parameters: parameters)
        as StoreQuery<T>;
    return read(q);
  }

  Future<List<T>> getMultiple<T>(
    DBQueries query, {
    List<Object?>? parameters,
  }) async {
    final q = getQuery(DBQueries.collectionById, parameters: parameters)
        as StoreQuery<T>;
    return (await readMultiple<T>(q)).nonNullableList;
  }

  Future<Collection?> getCollectionByID(int id) async =>
      get<Collection>(DBQueries.collectionById, parameters: [id]);

  Future<Collection?> getCollectionByLabel(String label) async =>
      get(DBQueries.collectionByLabel, parameters: [label]);

  Future<Collection?> getCollectionById(int id) async =>
      get(DBQueries.collectionById, parameters: [id]);

  Future<CLMedia?> getMediaByID(int id) async =>
      get(DBQueries.mediaById, parameters: [id]);

  Future<List<Collection>> getCollectionsByIDList(List<int> idList) async =>
      getMultiple(
        DBQueries.collectionByIdList,
        parameters: ['(${idList.join(', ')})'],
      );

  Future<List<CLMedia>> getMediasByIDList(List<int> idList) async =>
      getMultiple(
        DBQueries.mediaByIdList,
        parameters: ['(${idList.join(', ')})'],
      );

  Future<List<CLMedia>> getMediaByCollectionId(int collectionId) async =>
      getMultiple(
        DBQueries.mediaByCollectionId,
        parameters: [collectionId],
      );

  Future<List<CLMedia>> getNotesByMediaId(int mediaId) async =>
      getMultiple(DBQueries.notesByMediaId, parameters: [mediaId]);

  Future<List<CLMedia>?> getMediaByNoteId(int noteId) async =>
      getMultiple(DBQueries.mediaByNoteID, parameters: [noteId]);

  Future<List<Collection>?> getCollectionAll() async =>
      getMultiple(DBQueries.collectionsAll);

  Future<List<CLMedia>> getMediaAll() async => getMultiple(DBQueries.mediaAll);

  Future<List<CLMedia>> getNotesAll() async => getMultiple(DBQueries.notesAll);

  Future<CLMedia?> getMediaByServerUID(int serverUID) async => get(
        DBQueries.mediaByServerUID,
        parameters: [serverUID],
      );

  Future<CLMedia?> getMediaById(int id) async => get(
        DBQueries.mediaById,
        parameters: [id],
      );

  Future<CLMedia?> getMediaByMD5String(String md5String) async => get(
        DBQueries.mediaByMD5,
        parameters: [md5String],
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
