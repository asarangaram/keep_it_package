import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:store/src/store/models/cl_media.dart';
import 'package:store/src/store/models/collection.dart';
import 'package:store/src/store/models/tag.dart';

import 'db_manager.dart';

class DBUpdaterNotifier extends StateNotifier<int> {
  DBUpdaterNotifier(this.ref) : super(0);
  Ref ref;
  String? _pathPrefix;
  Future<Database> get db async =>
      (await ref.watch(dbManagerProvider.future)).db;
  Future<String> get pathPrefix async =>
      _pathPrefix ??= (await getApplicationDocumentsDirectory()).path;

  void refreshProviders() {
    state = state + 1;
  }

  Future<void> _replaceTags(Collection collection, List<Tag> tags) async {
    final updatedTags = <Tag>[];
    for (final tag in tags) {
      if (tag.id == null) {
        updatedTags.add(tag.upsert(await db));
      } else {
        updatedTags.add(tag);
      }
    }
    final existingTags = TagDB.getByCollectionId(await db, collection.id!);

    final existingTagsIds = existingTags.map((e) => e.id);
    final updatedTagsIds = updatedTags.map((e) => e.id);

    final tagsAdded = updatedTagsIds
      ..where((item) => !existingTagsIds.contains(item)).toList();
    final tagsRemoved = existingTagsIds
      ..where((item) => !updatedTagsIds.contains(item)).toList();

    if (tagsAdded.isNotEmpty) {
      for (final tagId in tagsAdded) {
        collection.addTag(await db, tagId!);
      }
    }
    if (tagsRemoved.isNotEmpty) {
      for (final tagId in tagsRemoved) {
        collection.removeTag(await db, tagId!);
      }
    }
  }

  Future<Collection> _upsertCollection({
    required Collection collection,
    required List<Tag>? tags,

    // required CLMedia? Function(CLMedia media) onGetDuplicate,
  }) async {
    final collectionUpdated = collection.upsert(await db);
    if (tags != null) {
      await _replaceTags(collectionUpdated, tags);
    }

    return collectionUpdated;
  }

  Future<void> upsertCollection({
    required Collection collection,
    required List<Tag>? tags,
    required void Function({required CLMediaList? mg}) onDone,
    // required CLMedia? Function(CLMedia media) onGetDuplicate,
  }) async {
    await _upsertCollection(collection: collection, tags: tags);

    onDone(mg: null);
    refreshProviders();
  }

  Stream<Progress> upsertMediaList({
    required CLMediaList media,
    required void Function({required CLMediaList? mg}) onDone,
    // required CLMedia? Function(CLMedia media) onGetDuplicate,
  }) async* {
    // Collections must be non null
    // Atleast one item must be there
    // tag can be empty, but can't be null
    if (media.collection == null || media.entries.isEmpty) {
      throw Exception("Can't handle $media");
    }

    yield Progress(currentItem: media.entries[0].basename, fractCompleted: 0);

    final collection = await _upsertCollection(
      collection: media.collection!,
      tags: media.tags,
    );

    for (final (i, item0) in media.entries.indexed) {
      final item1 = item0.copyWith(collectionId: collection.id);
      if (item1.isValidMedia) {
        final item = await (await item1.copyFile(pathPrefix: await pathPrefix))
            .getMetadata();
        item.upsert(await db, pathPrefix: await pathPrefix);
      }
      yield Progress(
        currentItem: (i + 1 == media.entries.length)
            ? 'Completed Successfull'
            : media.entries[i + 1].basename,
        fractCompleted: (i + 1) / media.entries.length,
      );
    }

    yield const Progress(
      currentItem: '',
      fractCompleted: 1,
    );
    refreshProviders();
    onDone(mg: null);
  }

  Future<Tag> upsertTag(Tag tag) async {
    final tagWithID = tag.upsert(await db);
    refreshProviders();
    return tagWithID;
  }

  /* 
  Future<void> upsertMediaList(CLMediaList mediaList) async {
    if (mediaList.collection == null) {
      throw Exception('collection not specified');
    }
    final updatedCollectionID = mediaList.collection!.upsert(await db);
    
  } */

  /* Future<void> upsertItem(CLMedia item) async {
    final updated = item.upsert(await db, pathPrefix: await pathPrefix);
    refreshItem({updated.collectionId!});
  } */

  /* Future<void> upsertItems(List<CLMedia> items) async {
    final collectionIdList = <int>{};
    for (final item in items) {
      final updated = item.upsert(await db, pathPrefix: await pathPrefix);
      collectionIdList.add(updated.collectionId!);
    }
    refreshItem(collectionIdList);
  } */

  /* Future<void> deleteCollection(Collection collection) async {}
  Future<void> deleteCollections(List<Collection> collections) async {}
  Future<void> deleteTag(Tag tag) async {}
  Future<void> deleteTags(List<Tag> tag) async {} */

  Future<void> deleteItem(CLMedia item) async {
    if (item.id == null || item.collectionId == null) {
      if (kDebugMode) {
        throw Exception("id and collectonID can't be null");
      }
      return;
    }

    item
      ..deleteFile()
      ..delete(await db);

    refreshProviders();
  }

  Future<void> deleteItems(List<CLMedia> items) async {
    final collectionIdList = <int>{};
    for (final item in items) {
      if (item.id == null || item.collectionId == null) {
        if (kDebugMode) {
          throw Exception("id and collectonID can't be null");
        }
        return;
      }
      collectionIdList.add(item.collectionId!);
      item
        ..deleteFile()
        ..delete(await db);
    }
    refreshProviders();
  }
}

final dbUpdaterNotifierProvider =
    StateNotifierProvider<DBUpdaterNotifier, int>((ref) {
  return DBUpdaterNotifier(ref);
});
