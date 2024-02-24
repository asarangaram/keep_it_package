import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
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

  void refreshItem(Set<int> collectionIdList) {
    for (final id in collectionIdList) {
      ref
        ..read(clMediaListByCollectionIdProvider(id))
        ..read(tagsProvider(id));
    }
    ref
      ..read(tagsProvider(null))
      ..read(collectionsProvider(null));

    for (final id in collectionIdList) {
      ref
        ..read(clMediaListByCollectionIdProvider(id).notifier).loadItems()
        ..read(tagsProvider(id).notifier).loadTags();
    }
    ref
      ..read(tagsProvider(null).notifier).loadTags()
      ..read(collectionsProvider(null).notifier).loadCollections();
  }

  Future<void> upsertItem(CLMedia item) async {
    final updated = item.upsert(await db, pathPrefix: await pathPrefix);
    refreshItem({updated.collectionId!});
  }

  Future<void> upsertItems(List<CLMedia> items) async {
    final collectionIdList = <int>{};
    for (final item in items) {
      final updated = item.upsert(await db, pathPrefix: await pathPrefix);
      collectionIdList.add(updated.collectionId!);
    }
    refreshItem(collectionIdList);
  }

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

    refreshItem({collectionID});
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
    refreshItem(collectionIdList);
  }
}

final dbUpdaterNotifierProvider =
    StateNotifierProvider<DBUpdaterNotifier, int>((ref) {
  return DBUpdaterNotifier(ref);
});
