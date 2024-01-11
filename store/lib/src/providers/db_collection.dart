import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/collection.dart';
import '../models/db.dart';
import 'db_manager.dart';

class CollectionNotifier extends StateNotifier<AsyncValue<Collections>> {
  CollectionNotifier({
    this.databaseManager,
    this.clusterId,
  }) : super(const AsyncValue.loading()) {
    loadCollections();
  }
  DatabaseManager? databaseManager;
  int? clusterId;

  bool isLoading = false;
  // Some race condition might occuur if many collections are updated
  /// How to avoid more frequent update if many triggers occur one after other.
  Future<void> loadCollections() async {
    if (databaseManager == null) return;
    final List<Collection> collections;

    if (clusterId == null) {
      collections = CollectionDB.getAll(databaseManager!.db);
    } else {
      collections = CollectionDB.getCollectionsForCluster(
        databaseManager!.db,
        clusterId!,
      );
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return Collections(collections);
    });
  }

  void upsertCollection(Collection collection) {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }

    collection.upsert(databaseManager!.db);

    loadCollections();
  }

  void upsertCollections(List<Collection> collections) {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }
    for (final collection in collections) {
      collection.upsert(databaseManager!.db);
    }
    loadCollections();
  }

  void deleteCollection(Collection collection) {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }

    collection.delete(databaseManager!.db);
    loadCollections();
  }

  void deleteCollections(List<Collection> collections) {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }
    for (final collection in collections) {
      collection.delete(databaseManager!.db);
    }
    loadCollections();
  }
}

final collectionsProvider = StateNotifierProvider.family<CollectionNotifier,
    AsyncValue<Collections>, int?>((ref, clusterId) {
  final dbManagerAsync = ref.watch(dbManagerProvider);
  return dbManagerAsync.when(
    data: (DatabaseManager dbManager) =>
        CollectionNotifier(databaseManager: dbManager, clusterId: clusterId),
    error: (_, __) => CollectionNotifier(),
    loading: CollectionNotifier.new,
  );
});
