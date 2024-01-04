import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/item.dart';
import '../models/db.dart';
import 'db_manager.dart';

class ItemNotifier extends StateNotifier<AsyncValue<Items>> {
  DatabaseManager? databaseManager;
  int? clusterID;
  Ref ref;

  bool isLoading = false;
  ItemNotifier({
    required this.ref,
    this.databaseManager,
    this.clusterID,
  }) : super(const AsyncValue.loading()) {
    loadItems();
  }

  loadItems() async {
    if (databaseManager == null) return;
    final List<ItemInDB> items;

    if (clusterID == null) {
      items = ItemDB.getAll(databaseManager!.db);
    } else {
      items = ItemDB.getItemsForCluster(databaseManager!.db, clusterID!);
    }
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return Items(items);
    });
  }

  void upsertItem(ItemInDB item) {
    if (databaseManager == null) {
      throw Exception("DB Manager is not ready");
    }

    item.upsert(databaseManager!.db);
    //ref.invalidate(itemsProvider(item.clusterId));

    loadItems();
  }

  /*  void upsertItems(List<Item> items) {
    if (databaseManager == null) {
      throw Exception("DB Manager is not ready");
    }
    for (var item in items) {
      item.upsert(databaseManager!.db);
    }
    loadItems();
  } */

  void deleteItem(ItemInDB item) {
    if (databaseManager == null) {
      throw Exception("DB Manager is not ready");
    }

    item.delete(databaseManager!.db);
    loadItems();
  }

  void deleteItems(List<ItemInDB> items) {
    if (databaseManager == null) {
      throw Exception("DB Manager is not ready");
    }
    for (var item in items) {
      item.delete(databaseManager!.db);
    }
    loadItems();
  }
}

final itemsProvider =
    StateNotifierProvider.family<ItemNotifier, AsyncValue<Items>, int?>(
        (ref, clusterID) {
  final dbManagerAsync = ref.watch(dbManagerProvider);
  return dbManagerAsync.when(
    data: (DatabaseManager dbManager) => ItemNotifier(
        ref: ref, databaseManager: dbManager, clusterID: clusterID),
    error: (_, __) => ItemNotifier(
      ref: ref,
    ),
    loading: () => ItemNotifier(
      ref: ref,
    ),
  );
});
