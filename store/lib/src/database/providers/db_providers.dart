// ignore_for_file: unused_local_variable

import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

import '../../device/models/device_directories.dart';
import '../../device/providers/device_directories.dart';
import '../models/cl_media.dart';
import '../models/collection.dart';
import '../models/tag.dart';
import 'db_manager.dart';
import 'db_updater.dart';

final _resourcesProvider =
    FutureProvider<(Database, DeviceDirectories)>((ref) async {
  final updatedChanged = ref.watch(dbUpdaterNotifierProvider);
  final db = (await ref.watch(dbManagerProvider.future)).db;
  final docDir = await ref.watch(docDirProvider.future);

  _infoLogger('Refreshing resources');
  return (db, docDir);
});

final getTagsByCollectionId =
    FutureProvider.family<Tags, int?>((ref, collectionId) async {
  final List<Tag> tags;
  final (db, _) = await ref.watch(_resourcesProvider.future);
  if (collectionId == null) {
    tags = TagDB.getAll(db);
  } else {
    tags = TagDB.getByCollectionId(db, collectionId);
  }
  _infoLogger('Loading Tags for collection.id = $collectionId');
  return Tags(tags);
});

final getCollectionsByTagId =
    FutureProvider.family<Collections, int?>((ref, tagId) async {
  final (db, _) = await ref.watch(_resourcesProvider.future);
  final List<Collection> collections;
  final Tag? tag;
  if (tagId == null) {
    collections = CollectionDB.getAll(db);
    tag = null;
  } else {
    collections = CollectionDB.getByTagId(db, tagId);
    tag = TagDB.getById(db, tagId);
  }
  _infoLogger('Loading Collections for tag.id = $tagId');
  return Collections(collections, tag: tag);
});

final getCollectionById =
    FutureProvider.family<Collection, int>((ref, id) async {
  final (db, _) = await ref.watch(_resourcesProvider.future);
  _infoLogger('Loading Collection for id = $id');
  return CollectionDB.getById(db, id);
});

final getMediaByTagId =
    FutureProvider.family<List<CLMedia>, int>((ref, tagID) async {
  final (db, docDir) = await ref.watch(_resourcesProvider.future);
  _infoLogger('Loading Media by tag.id = $tagID');
  return CLMediaDB.getByTagId(db, tagID, pathPrefix: docDir.docDir.path);
});

final getMediaByCollectionId =
    FutureProvider.family<CLMediaList, int>((ref, collectionId) async {
  final (db, docDir) = await ref.watch(_resourcesProvider.future);
  final collection = CollectionDB.getById(db, collectionId);
  final entries = CLMediaDB.getByCollectionId(db, collectionId,
      pathPrefix: docDir.docDir.path);
  _infoLogger('Loading Media by collection.id = $collectionId');
  return CLMediaList(entries: entries, collection: collection);
});

bool _disableInfoLogger = true;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
