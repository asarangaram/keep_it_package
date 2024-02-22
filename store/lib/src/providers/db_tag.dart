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

  Tag _upsertTag(Tag tag) {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }

    final lastupdatedID = tag.upsert(databaseManager!.db);

    final tagWithID = TagDB.getById(databaseManager!.db, lastupdatedID);

    return tagWithID;
  }

  Future<Tag> upsertTag(Tag tag) async {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }
    final tagWithID = _upsertTag(tag);
    await loadTags(lastupdatedID: tagWithID.id);
    return tagWithID;
  }

  Future<Iterable<Tag>> upsertTags(Iterable<Tag> tags) async {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }
    final tagsWithID = <Tag>[];

    for (final tag in tags) {
      tagsWithID.add(_upsertTag(tag));
    }
    await loadTags();
    return tagsWithID;
  }

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
