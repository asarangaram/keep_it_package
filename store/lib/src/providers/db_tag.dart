import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/db.dart';
import '../models/tag.dart';
import 'db_manager.dart';

class TagNotifier extends StateNotifier<AsyncValue<Tags>> {
  TagNotifier({
    this.databaseManager,
    this.collectionId,
  }) : super(const AsyncValue.loading()) {
    loadTags();
  }
  DatabaseManager? databaseManager;
  int? collectionId;

  bool isLoading = false;
  // Some race condition might occuur if many tags are updated
  /// How to avoid more frequent update if many triggers occur one after other.
  Future<void> loadTags({int? lastupdatedID}) async {
    if (databaseManager == null) return;
    final List<Tag> tags;

    if (collectionId == null) {
      tags = TagDB.getAll(databaseManager!.db);
    } else {
      tags = TagDB.getTagsByCollectionID(
        databaseManager!.db,
        collectionId!,
      );
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final res = Tags(tags, lastupdatedID: lastupdatedID);
      if (lastupdatedID != null) {
        Future.delayed(
          const Duration(seconds: 5),
          loadTags,
        );
      }
      return res;
    });
  }

  Tag upsertTag(Tag tag) {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }

    final lastupdatedID = tag.upsert(databaseManager!.db);

    loadTags(lastupdatedID: lastupdatedID);
    final tagWithID = TagDB.getById(databaseManager!.db, lastupdatedID);

    return tagWithID;
  }

  /* void upsertTags(List<Tag> tags) {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }
    for (final tag in tags) {
      tag.upsert(databaseManager!.db);
    }
    loadTags();
  } */

  Future<int> deleteTag(Tag tag) async {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }
    if (tag.id != null) {
      tag.delete(databaseManager!.db);
      await loadTags();
      return tag.id!;
    }
    return -1;
  }
}

final tagsProvider =
    StateNotifierProvider.family<TagNotifier, AsyncValue<Tags>, int?>(
        (ref, collectionId) {
  final dbManagerAsync = ref.watch(dbManagerProvider);
  return dbManagerAsync.when(
    data: (DatabaseManager dbManager) =>
        TagNotifier(databaseManager: dbManager, collectionId: collectionId),
    error: (_, __) => TagNotifier(),
    loading: TagNotifier.new,
  );
});
