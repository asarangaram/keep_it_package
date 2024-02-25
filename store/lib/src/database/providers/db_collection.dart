import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/collection.dart';
import '../models/db_manager.dart';
import '../models/tag.dart';

import 'db_manager.dart';

class CollectionsNotifier extends StateNotifier<AsyncValue<Collections>> {
  CollectionsNotifier({
    required this.ref,
    this.databaseManager,
    this.tagId,
  }) : super(const AsyncValue.loading()) {
    load();
  }
  DBManager? databaseManager;
  int? tagId;
  Ref ref;

  bool isLoading = false;

  Future<void> load() async {
    if (databaseManager == null) return;
    final List<Collection> collections;
    final Tag? tag;
    if (tagId == null) {
      collections = CollectionDB.getAll(databaseManager!.db);
      tag = null;
    } else {
      collections = CollectionDB.getByTagId(
        databaseManager!.db,
        tagId!,
      );
      tag = TagDB.getById(databaseManager!.db, tagId!);
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return Collections(collections, tag: tag);
    });
  }

  Future<int> deleteCollection(
    Collection collection,
  ) async {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }
    if (collection.id != null) {
      collection.delete(databaseManager!.db);
      await load();
      return collection.id!;
    }
    return -1;
  }
}

final collectionsProvider = StateNotifierProvider.family<CollectionsNotifier,
    AsyncValue<Collections>, int?>((ref, collectionId) {
  final dbManagerAsync = ref.watch(dbManagerProvider);
  return dbManagerAsync.when(
    data: (DBManager dbManager) => CollectionsNotifier(
      ref: ref,
      databaseManager: dbManager,
      tagId: collectionId,
    ),
    error: (_, __) => CollectionsNotifier(
      ref: ref,
    ),
    loading: () => CollectionsNotifier(
      ref: ref,
    ),
  );
});

final collectionProvider =
    FutureProvider.family<Collection, int>((ref, id) async {
  final db = (await ref.watch(dbManagerProvider.future)).db;
  return CollectionDB.getById(db, id);
});
