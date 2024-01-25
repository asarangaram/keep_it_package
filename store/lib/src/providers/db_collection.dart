import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/collection.dart';
import '../models/db.dart';
import 'db_manager.dart';

class TagNotifier extends StateNotifier<AsyncValue<Tags>> {
  TagNotifier({
    this.databaseManager,
    this.clusterId,
  }) : super(const AsyncValue.loading()) {
    loadTags();
  }
  DatabaseManager? databaseManager;
  int? clusterId;

  bool isLoading = false;
  // Some race condition might occuur if many collections are updated
  /// How to avoid more frequent update if many triggers occur one after other.
  Future<void> loadTags({int? lastupdatedID}) async {
    if (databaseManager == null) return;
    final List<Tag> collections;

    if (clusterId == null) {
      collections = TagDB.getAll(databaseManager!.db);
    } else {
      collections = TagDB.getTagsForCluster(
        databaseManager!.db,
        clusterId!,
      );
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final res = Tags(collections, lastupdatedID: lastupdatedID);
      if (lastupdatedID != null) {
        Future.delayed(
          const Duration(seconds: 5),
          loadTags,
        );
      }
      return res;
    });
  }

  void upsertTag(Tag collection) {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }

    final lastupdatedID = collection.upsert(databaseManager!.db);

    loadTags(lastupdatedID: lastupdatedID);
  }

  void upsertTags(List<Tag> collections) {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }
    for (final collection in collections) {
      collection.upsert(databaseManager!.db);
    }
    loadTags();
  }

  void deleteTag(Tag collection) {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }

    collection.delete(databaseManager!.db);
    loadTags();
  }

  void deleteTags(List<Tag> collections) {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }
    for (final collection in collections) {
      collection.delete(databaseManager!.db);
    }
    loadTags();
  }
}

final collectionsProvider =
    StateNotifierProvider.family<TagNotifier, AsyncValue<Tags>, int?>(
        (ref, clusterId) {
  final dbManagerAsync = ref.watch(dbManagerProvider);
  return dbManagerAsync.when(
    data: (DatabaseManager dbManager) =>
        TagNotifier(databaseManager: dbManager, clusterId: clusterId),
    error: (_, __) => TagNotifier(),
    loading: TagNotifier.new,
  );
});
