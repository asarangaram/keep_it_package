import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/db_manager.dart';

import '../models/tag.dart';
import 'db_manager.dart';

class TagNotifier extends StateNotifier<AsyncValue<Tags>> {
  TagNotifier({
    this.databaseManager,
    this.collectionId,
  }) : super(const AsyncValue.loading()) {
    load();
  }
  DBManager? databaseManager;
  int? collectionId;

  bool isLoading = false;
  // Some race condition might occuur if many tags are updated
  /// How to avoid more frequent update if many triggers occur one after other.
  Future<void> load({int? lastupdatedID}) async {
    if (databaseManager == null) return;
    final List<Tag> tags;

    if (collectionId == null) {
      tags = TagDB.getAll(databaseManager!.db);
    } else {
      tags = TagDB.getByCollectionId(
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
          load,
        );
      }
      return res;
    });
  }
}

final tagsProvider =
    StateNotifierProvider.family<TagNotifier, AsyncValue<Tags>, int?>(
        (ref, collectionId) {
  final dbManagerAsync = ref.watch(dbManagerProvider);
  return dbManagerAsync.when(
    data: (DBManager dbManager) =>
        TagNotifier(databaseManager: dbManager, collectionId: collectionId),
    error: (_, __) => TagNotifier(),
    loading: TagNotifier.new,
  );
});
