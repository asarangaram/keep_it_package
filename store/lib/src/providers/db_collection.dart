import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../models/db.dart';
import 'db_manager.dart';

class CollectionsNotifier extends StateNotifier<AsyncValue<Collections>> {
  CollectionsNotifier({
    required this.ref,
    this.databaseManager,
    this.tagID,
  }) : super(const AsyncValue.loading()) {
    loadCollections();
  }
  DatabaseManager? databaseManager;
  int? tagID;
  Ref ref;

  bool isLoading = false;

  Future<void> loadCollections() async {
    if (databaseManager == null) return;
    final List<Collection> collections;
    final Tag? tag;
    if (tagID == null) {
      collections = CollectionDB.getAll(databaseManager!.db);
      tag = null;
    } else {
      collections = CollectionDB.getCollectionsByTagID(
        databaseManager!.db,
        tagID!,
      );
      tag = TagDB.getById(databaseManager!.db, tagID!);
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
        if (id != tagID) {
          await ref.read(collectionsProvider(id).notifier).loadCollections();
        } else {
          await loadCollections();
        }

        ref.invalidate(itemsByTagIdProvider(DBQueries.byTagID(id)));
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
    AsyncValue<Collections>, int?>((ref, collectionID) {
  final dbManagerAsync = ref.watch(dbManagerProvider);
  return dbManagerAsync.when(
    data: (DatabaseManager dbManager) => CollectionsNotifier(
      ref: ref,
      databaseManager: dbManager,
      tagID: collectionID,
    ),
    error: (_, __) => CollectionsNotifier(
      ref: ref,
    ),
    loading: () => CollectionsNotifier(
      ref: ref,
    ),
  );
});
