import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:store/src/database/models/collection.dart';
import 'package:store/src/database/models/tag.dart';
import 'package:store/store.dart';

import 'db_manager.dart';

class DBUpdaterNotifier extends StateNotifier<int> {
  DBUpdaterNotifier(this.ref) : super(0);
  Ref ref;
  String? _pathPrefix;
  Future<Database> get db async =>
      (await ref.watch(dbManagerProvider.future)).db;
  Future<String> get pathPrefix async =>
      _pathPrefix ??= (await getApplicationDocumentsDirectory()).path;

  void refreshProviders({Set<int>? collectionIdList, Set<int>? tagIdList}) {
    state = state + 1;
    /* if (collectionIdList?.isNotEmpty ?? false) {
      for (final id in collectionIdList!) {
        ref
          ..read(clMediaListByCollectionIdProvider(id).notifier).loadItems()
          ..read(tagsProvider(id).notifier).load();
      }
    }
    if (tagIdList?.isNotEmpty ?? false) {
      for (final tagId in tagIdList!) {
        ref.read(collectionsProvider(tagId).notifier).load();
      }
    }
    ref
      ..read(tagsProvider(null).notifier).load()
      ..read(collectionsProvider(null).notifier).load(); */
  }

  Future<void> replaceTags(Collection collection, List<Tag> tags) async {
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

  Stream<Progress> upsertCollection({
    required Collection collection,
    required List<Tag> tags,
    required void Function({required CLMediaList? mg}) onDone,
    // required CLMedia? Function(CLMedia media) onGetDuplicate,
  }) async* {
    final collectionUpdated = collection.upsert(await db);
    await replaceTags(collectionUpdated, tags);
    refreshProviders(collectionIdList: {collectionUpdated.id!});
  }

  Stream<Progress> upsertMediaList({
    required CLMediaList media,
    required void Function({required CLMediaList? mg}) onDone,
    // required CLMedia? Function(CLMedia media) onGetDuplicate,
  }) async* {
    // Collections must be non null
    // Atleast one item must be there
    // tag can be empty, but can't be null
    if (media.collection == null ||
        media.entries.isEmpty ||
        media.tags == null) {
      throw Exception("Can't handle $media");
    }

    yield Progress(currentItem: media.entries[0].basename, fractCompleted: 0);
    final collection = media.collection!.upsert(await db);
    final updated = <CLMedia>[];
    for (final (i, item0) in media.entries.indexed) {
      final item = item0;
      updated.add(
        await (await item
                .copyWith(collectionId: collection.id)
                .copyFile(pathPrefix: await pathPrefix))
            .getMetadata(),
      );
      // Artificial delay
      await Future<void>.delayed(const Duration(milliseconds: 100));
      yield Progress(
        currentItem: (i + 1 == media.entries.length)
            ? 'Save Media into DB'
            : media.entries[i + 1].basename,
        fractCompleted: ((i + 1) / media.entries.length) * 0.9,
      );
    }

    final mediaListNew = <CLMedia>[];
    for (final item in updated) {
      mediaListNew.add(item.upsert(await db, pathPrefix: await pathPrefix));
    }
    yield const Progress(
      currentItem: 'Processing Tags',
      fractCompleted: 0.92,
    );
    // Process Tags
    await replaceTags(collection, media.tags!);
    refreshProviders(collectionIdList: {collection.id!});
    yield const Progress(
      currentItem: 'Completed Successfull',
      fractCompleted: 1,
    );
    onDone(mg: null);
  }

  Future<Tag> upsertTag(Tag tag) async {
    final tagWithID = tag.upsert(await db);
    refreshProviders(tagIdList: {tagWithID.id!});
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

  Future<void> deleteCollection(Collection collection) async {}
  Future<void> deleteCollections(List<Collection> collections) async {}
  Future<void> deleteTag(Tag tag) async {}
  Future<void> deleteTags(List<Tag> tag) async {}

  Future<void> deleteItem(CLMedia item) async {
    if (item.id == null || item.collectionId == null) {
      if (kDebugMode) {
        throw Exception("id and collectonID can't be null");
      }
      return;
    }
    final collectionID = item.collectionId!;
    item
      ..deleteFile()
      ..delete(await db);

    refreshProviders(collectionIdList: {collectionID});
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
    refreshProviders(collectionIdList: collectionIdList);
  }
}

final dbUpdaterNotifierProvider =
    StateNotifierProvider<DBUpdaterNotifier, int>((ref) {
  return DBUpdaterNotifier(ref);
});
