import 'dart:io';

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
    required this.collectionID,
    this.databaseManager,
  }) : super(const AsyncValue.loading()) {
    loadItems();
  }
  DatabaseManager? databaseManager;
  int collectionID;
  Ref ref;
  String? _pathPrefix;
  bool isLoading = false;

  Future<String> get pathPrefix async =>
      _pathPrefix ??= (await getApplicationDocumentsDirectory()).path;

  Future<void> loadItems() async {
    if (databaseManager == null) return;
    final List<CLMedia> items;
    final Collection collection;

    items = ExtItemInDB.dbGetByCollectionId(
      databaseManager!.db,
      collectionID,
      pathPrefix: await pathPrefix,
    );
    collection = CollectionDB.getById(databaseManager!.db, collectionID);

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return Items(collection: collection, entries: items);
    });
  }

  Future<void> upsertItem(CLMedia item) async {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }
    final prefix = await pathPrefix;

    (await item.copyFile(
      pathPrefix: prefix,
    ))
        .dbUpsert(
      databaseManager!.db,
      pathPrefix: prefix,
    );

    await loadItems();
  }

  Future<void> upsertItems(List<CLMedia> items) async {
    if (databaseManager == null) {
      print('DB Not ready, not saved !');
      return;
      //throw Exception('DB Manager is not ready');
    }
    final prefix = await pathPrefix;
    for (final item in items) {
      (await item.copyFile(
        pathPrefix: prefix,
      ))
          .dbUpsert(
        databaseManager!.db,
        pathPrefix: prefix,
      );
    }
    await loadItems();
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
    StateNotifierProvider.family<ItemNotifier, AsyncValue<Items>, int>(
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
      collectionID: collectionID,
    ),
    loading: () => ItemNotifier(
      ref: ref,
      collectionID: collectionID,
    ),
  );
});

final docDirProvider = FutureProvider<Directory>((ref) async {
  return getApplicationDocumentsDirectory();
});
