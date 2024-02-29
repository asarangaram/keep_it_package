import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/resources.dart';

import 'db_updater.dart';
import 'device_directories.dart';

final resourcesProvider = FutureProvider<Resources>((ref) async {
  // ignore: unused_local_variable
  final updatedChanged = ref.watch(dbUpdaterNotifierProvider);

  _infoLogger('Refreshing resources');
  return Resources(
    directories: await ref.watch(deviceDirectoriesProvider.future),
  );
});
/* 
final getTagsByCollectionId =
    FutureProvider.family<Tags, int?>((ref, collectionId) async {
  final List<Tag> tags;
  final resources = await ref.watch(resourcesProvider.future);
  if (collectionId == null) {
    tags = TagDB.getAll(resources.db);
  } else {
    tags = TagDB.getByCollectionId(resources.db, collectionId);
  }
  _infoLogger('Loading Tags for collection.id = $collectionId');
  return Tags(tags);
});
final getNonEmptyTagsByCollectionId =
    FutureProvider.family<Tags, int?>((ref, collectionId) async {
  final List<Tag> tags;
  final resources = await ref.watch(resourcesProvider.future);
  if (collectionId == null) {
    tags = TagDB.getAll(resources.db, includeEmpty: false);
  } else {
    tags = TagDB.getByCollectionId(
      resources.db,
      collectionId,
    );
  }
  _infoLogger('Loading Non  Empty Tags for collection.id = $collectionId');
  return Tags(tags);
});

final getCollectionsByTagId =
    FutureProvider.family<Collections, int?>((ref, tagId) async {
  final resources = await ref.watch(resourcesProvider.future);
  final List<Collection> collections;
  final Tag? tag;
  if (tagId == null) {
    collections = CollectionDB.getAll(resources.db);
    tag = null;
  } else {
    collections = CollectionDB.getByTagId(resources.db, tagId);
    tag = TagDB.getById(resources.db, tagId);
  }
  _infoLogger('Loading Collections for tag.id = $tagId');
  return Collections(collections, tag: tag);
});

final getNonEmptyCollectionsByTagId =
    FutureProvider.family<Collections, int?>((ref, tagId) async {
  final resources = await ref.watch(resourcesProvider.future);
  final List<Collection> collections;
  final Tag? tag;
  if (tagId == null) {
    collections = CollectionDB.getAll(resources.db, includeEmpty: false);
    tag = null;
  } else {
    collections =
        CollectionDB.getByTagId(resources.db, tagId, includeEmpty: false);
    tag = TagDB.getById(resources.db, tagId);
  }
  _infoLogger('Loading Non  Empty Collections for tag.id = $tagId');
  return Collections(collections, tag: tag);
});

final getCollectionById =
    FutureProvider.family<Collection, int>((ref, id) async {
  final resources = await ref.watch(resourcesProvider.future);
  _infoLogger('Loading Collection for id = $id');
  return CollectionDB.getById(resources.db, id);
});

final getMediaByTagId =
    FutureProvider.family<List<CLMedia>, int>((ref, tagID) async {
  final resources = await ref.watch(resourcesProvider.future);
  _infoLogger('Loading Media by tag.id = $tagID');
  return CLMediaDB.getByTagId(
    resources.db,
    tagID,
    pathPrefix: resources.directories.docDir.path,
  );
});

final getMediaByCollectionId =
    FutureProvider.family<List<CLMedia>, int>((ref, collectionId) async {
  final resources = await ref.watch(resourcesProvider.future);

  final entries = CLMediaDB.getByCollectionId(
    resources.db,
    collectionId,
    pathPrefix: resources.directories.docDir.path,
  );
  _infoLogger('Loading Media by collection.id = $collectionId');
  return entries;
});
*/
bool _disableInfoLogger = false;
void _infoLogger(String msg) {
  if (!_disableInfoLogger) {
    logger.i(msg);
  }
}
