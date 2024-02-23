import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/db.dart';
import 'db_manager.dart';

class CollectionsNotifier extends StateNotifier<AsyncValue<Collections>> {
  CollectionsNotifier({
    required this.ref,
    this.databaseManager,
    this.tagId,
  }) : super(const AsyncValue.loading()) {
    loadCollections();
  }
  DatabaseManager? databaseManager;
  int? tagId;
  Ref ref;

  bool isLoading = false;

  Future<void> loadCollections() async {
    if (databaseManager == null) return;
    final List<Collection> collections;
    final Tag? tag;
    if (tagId == null) {
      collections = CollectionDB.getAll(databaseManager!.db);
      tag = null;
    } else {
      collections = CollectionDB.getCollectionsByTagId(
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

  Future<int> upsertCollection(
    Collection collection,
    List<int>? tagIds,
  ) async {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }

    // Save Collection and get Collection ID.
    // Associate it wtih all the TagIds
    // invalidate the collections queries by Tag id for all TagIds

    final collectionId = collection.upsert(databaseManager!.db);

    if (tagIds != null) {
      for (final id in tagIds) {
        CollectionDB.addTagToCollection(databaseManager!.db, id, collectionId);
        if (id != tagId) {
          await ref.read(collectionsProvider(id).notifier).loadCollections();
        } else {
          await loadCollections();
        }

        ref.invalidate(itemsByTagIdProvider(DBQueries.byTagId(id)));
      }
    }

    await loadCollections();

    return collectionId;
  }

  Future<int> deleteCollection(
    Collection collection,
  ) async {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }
    if (collection.id != null) {
      collection.delete(databaseManager!.db);
      await loadCollections();
      return collection.id!;
    }
    return -1;
  }
}

final collectionsProvider = StateNotifierProvider.family<CollectionsNotifier,
    AsyncValue<Collections>, int?>((ref, collectionId) {
  final dbManagerAsync = ref.watch(dbManagerProvider);
  return dbManagerAsync.when(
    data: (DatabaseManager dbManager) => CollectionsNotifier(
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
