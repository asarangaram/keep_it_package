import 'dart:io';

import 'package:store/store.dart';

import '../models/store_manager.dart';

extension ReadExtOnStoreManager on StoreManager {
  String loadText(CLMedia? media) {
    if (media?.type != CLMediaType.text) return '';
    final path = getMediaPath(media!);

    return File(path).existsSync()
        ? File(path).readAsStringSync()
        : 'Content Missing. File not found';
  }

  String getText(CLMedia? note) => loadText(note);

  Future<CLMedia?> getMediaById(
    int id,
  ) {
    final q = store.getQuery(
      DBQueries.mediaById,
      parameters: [id],
    ) as StoreQuery<CLMedia>;
    return store.read(q);
  }

  Future<List<CLMedia?>> getMediaByCollectionId(
    int collectionId,
  ) {
    final q = store.getQuery(
      DBQueries.mediaByCollectionId,
      parameters: [collectionId],
    ) as StoreQuery<CLMedia>;
    return store.readMultiple(q);
  }

  Future<List<CLMedia?>> getMediaMultipleByIds(
    List<int> idList,
  ) {
    final q = store.getQuery(
      DBQueries.mediaByIdList,
      parameters: ['(${idList.join(', ')})'],
    ) as StoreQuery<CLMedia>;
    return store.readMultiple(q);
  }

  Future<Collection?> getCollectionByLabel(
    String label,
  ) async {
    final q = store.getQuery(
      DBQueries.collectionByLabel,
      parameters: [label],
    ) as StoreQuery<Collection>;
    return store.read(q);
  }

  Future<Collection?> getCollectionById(
    int id,
  ) async {
    final q = store.getQuery(
      DBQueries.collectionById,
      parameters: [id],
    ) as StoreQuery<Collection>;
    return store.read(q);
  }

  Future<CLMedia?> getMediaByMD5(
    String md5String,
  ) async {
    final q = store.getQuery(
      DBQueries.mediaByMD5,
      parameters: [md5String],
    ) as StoreQuery<CLMedia>;
    return store.read(q);
  }

  Future<List<CLMedia?>?> getOrphanNotes() {
    final q = store.getQuery(DBQueries.notesOrphan) as StoreQuery<CLMedia>;
    return store.readMultiple(q);
  }
}
