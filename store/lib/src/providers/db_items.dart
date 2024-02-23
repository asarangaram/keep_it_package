import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../models/db.dart';
import 'db_manager.dart';

class CLMediaListByCollectionIdNotifier
    extends StateNotifier<AsyncValue<CLMediaList>> {
  CLMediaListByCollectionIdNotifier({
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

    items = ExtItemInDB.dbGetByCollectionId(
      databaseManager!.db,
      collectionID,
      pathPrefix: await pathPrefix,
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return CLMediaList(targetID: collectionID, entries: items);
    });
  }

  Future<String> calculateMD5(File file) async {
    final content = await file.readAsBytes();
    final digest = md5.convert(content);
    return digest.toString();
  }

  Future<void> _upsertItem(CLMedia item) async {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }
    final prefix = await pathPrefix;
    item.dbUpsert(databaseManager!.db, pathPrefix: prefix);
    await loadItems();
  }

  Future<void> upsertItem(CLMedia item) async => _upsertItem(item);

  Future<void> upsertItems(List<CLMedia> items) async {
    if (databaseManager == null) {
      throw Exception('DB Manager is not ready');
    }
    for (final item in items) {
      await _upsertItem(item);
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

final clMediaListByCollectionIdProvider = StateNotifierProvider.family<
    CLMediaListByCollectionIdNotifier,
    AsyncValue<CLMediaList>,
    int>((ref, collectionID) {
  final dbManagerAsync = ref.watch(dbManagerProvider);

  return dbManagerAsync.when(
    data: (DatabaseManager dbManager) => CLMediaListByCollectionIdNotifier(
      ref: ref,
      databaseManager: dbManager,
      collectionID: collectionID,
    ),
    error: (_, __) => CLMediaListByCollectionIdNotifier(
      ref: ref,
      collectionID: collectionID,
    ),
    loading: () => CLMediaListByCollectionIdNotifier(
      ref: ref,
      collectionID: collectionID,
    ),
  );
});

final docDirProvider = FutureProvider<Directory>((ref) async {
  return getApplicationDocumentsDirectory();
});
