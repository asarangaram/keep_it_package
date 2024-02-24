import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:store/store.dart';

import 'db_manager.dart';

class DBUpdaterNotifier extends StateNotifier<int> {
  DBUpdaterNotifier(this.ref) : super(0);
  Ref ref;

  Future<Database> get db async =>
      (await ref.watch(dbManagerProvider.future)).db;

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

    ref
      ..invalidate(clMediaListByCollectionIdProvider(collectionID))
      ..invalidate(tagsProvider(collectionID))
      ..invalidate(tagsProvider(null))
      ..invalidate(collectionsProvider(null));
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
    for (final id in collectionIdList) {
      ref
        ..invalidate(clMediaListByCollectionIdProvider(id))
        ..invalidate(tagsProvider(id));
    }
    ref
      ..invalidate(tagsProvider(null))
      ..invalidate(collectionsProvider(null));
  }
}

final dbUpdaterNotifierProvider =
    StateNotifierProvider<DBUpdaterNotifier, int>((ref) {
  return DBUpdaterNotifier(ref);
});
