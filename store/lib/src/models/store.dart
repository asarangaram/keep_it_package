import 'cl_media.dart';

import 'collection.dart';

import 'download_media/media_status.dart';
import 'download_media/preference.dart';

enum DBQueries {
  collectionById,
  collectionByLabel,
  collectionsAll,
  collectionsExcludeEmpty,
  collectionsEmpty,
  collectionByIdList,

  mediaById,
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

  mediaPreferenceById,
  mediaStatusById
}

abstract class StoreQuery<T> {
  const StoreQuery();
}

abstract class Store {
  /// upsertCollection - introduce NULL return
  Future<Collection> upsertCollection(Collection collection);
  Future<CLMedia?> upsertMedia(CLMedia media, {List<CLMedia>? parents});
  //Future<CLMedia?> upsertNote(CLMedia note, List<CLMedia> mediaList);
  Future<void> upsertMediaPreference(MediaPreference pref);
  Future<void> upsertMediaStatus(MediaStatus status);

  Future<void> deleteCollection(Collection collection);
  Future<void> deleteMedia(CLMedia media);
  Future<void> deleteMediaPreference(MediaPreference pref);
  Future<void> deleteMediaStatus(MediaStatus status);

  Future<T?> read<T>(StoreQuery<T> query);

  Future<List<T?>> readMultiple<T>(StoreQuery<T> query);

  Future<void> reloadStore();

  Stream<List<T?>> storeReaderStream<T>(StoreQuery<T> storeQuery);
  StoreQuery<T> getQuery<T>(DBQueries query, {List<Object?>? parameters});

  void dispose();
}
