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
    required this.collectionId,
    this.databaseManager,
  }) : super(const AsyncValue.loading()) {
    loadItems();
  }
  DatabaseManager? databaseManager;
  int collectionId;
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
      collectionId,
      pathPrefix: await pathPrefix,
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return CLMediaList(collectionId: collectionId, entries: items);
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
    int>((ref, collectionId) {
  final dbManagerAsync = ref.watch(dbManagerProvider);

  return dbManagerAsync.when(
    data: (DatabaseManager dbManager) => CLMediaListByCollectionIdNotifier(
      ref: ref,
      databaseManager: dbManager,
      collectionId: collectionId,
    ),
    error: (_, __) => CLMediaListByCollectionIdNotifier(
      ref: ref,
      collectionId: collectionId,
    ),
    loading: () => CLMediaListByCollectionIdNotifier(
      ref: ref,
      collectionId: collectionId,
    ),
  );
});

final docDirProvider = FutureProvider<Directory>((ref) async {
  return getApplicationDocumentsDirectory();
});
