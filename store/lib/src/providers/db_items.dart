import 'package:colan_widgets/colan_widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../models/collection.dart';
import '../models/db.dart';
import '../models/item.dart';
import 'db_manager.dart';

class ItemNotifier extends StateNotifier<AsyncValue<Items>> {
  ItemNotifier({
    required this.ref,
    this.databaseManager,
    this.collectionID,
  }) : super(const AsyncValue.loading()) {
    getApplicationDocumentsDirectory().then((dir) {
      pathPrefix = dir.path;
      loadItems();
    });
  }
  DatabaseManager? databaseManager;
  int? collectionID;
  Ref ref;
  late final String? pathPrefix;

  bool isLoading = false;

  Future<void> loadItems() async {
    if (databaseManager == null) return;
    final List<CLMedia> items;
    final Collection collection;

    items = ExtItemInDB.dbGetByCollectionId(
      databaseManager!.db,
      collectionID!,
      pathPrefix: pathPrefix,
    );
    collection = CollectionDB.getById(databaseManager!.db, collectionID!);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return Items(collection, items);
    });
  }

  void upsertItem(CLMedia item) {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }

    item.dbUpsert(
      databaseManager!.db,
      pathPrefix: pathPrefix,
    );
    //ref.invalidate(itemsProvider(item.collectionId));

    loadItems();
  }

  void upsertItems(List<CLMedia> items) {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }
    for (final item in items) {
      upsertItem(item);
    }
    loadItems();
  }

  void deleteItem(CLMedia item) {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }

    item
      ..deleteFile()
      ..dbDelete(databaseManager!.db);

    loadItems();
  }

  void deleteItems(List<CLMedia> items) {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }
    for (final item in items) {
      item
        ..deleteFile()
        ..dbDelete(databaseManager!.db);
    }
    loadItems();
  }
}

final itemsProvider =
    StateNotifierProvider.family<ItemNotifier, AsyncValue<Items>, int?>(
        (ref, collectionID) {
  final dbManagerAsync = ref.watch(dbManagerProvider);
  return dbManagerAsync.when(
    data: (DatabaseManager dbManager) => ItemNotifier(
      ref: ref,
      databaseManager: dbManager,
      collectionID: collectionID,
    ),
    error: (_, __) => ItemNotifier(
      ref: ref,
    ),
    loading: () => ItemNotifier(
      ref: ref,
    ),
  );
});
