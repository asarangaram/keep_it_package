import 'dart:io';

import 'package:colan_widgets/colan_widgets.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:store/src/database/models/collection.dart';

import '../models/db_manager.dart';
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
  DBManager? databaseManager;
  int collectionId;
  Ref ref;
  String? _pathPrefix;
  bool isLoading = false;

  Future<String> get pathPrefix async =>
      _pathPrefix ??= (await getApplicationDocumentsDirectory()).path;

  Future<void> loadItems() async {
    if (databaseManager == null) return;
    final List<CLMedia> items;
    final collection = CollectionDB.getById(databaseManager!.db, collectionId);
    items = CLMediaDB.getByCollectionId(
      databaseManager!.db,
      collectionId,
      pathPrefix: await pathPrefix,
    );

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      return CLMediaList(collection: collection, entries: items);
    });
  }

  Future<String> calculateMD5(File file) async {
    final content = await file.readAsBytes();
    final digest = md5.convert(content);
    return digest.toString();
  }
}

final clMediaListByCollectionIdProvider = StateNotifierProvider.family<
    CLMediaListByCollectionIdNotifier,
    AsyncValue<CLMediaList>,
    int>((ref, collectionId) {
  final dbManagerAsync = ref.watch(dbManagerProvider);

  return dbManagerAsync.when(
    data: (DBManager dbManager) => CLMediaListByCollectionIdNotifier(
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

final clMediaListByTagIdProvider =
    FutureProvider.family<List<CLMedia>, int>((ref, tagID) async {
  final databaseManager = await ref.watch(dbManagerProvider.future);
  final pathPrefix = (await getApplicationDocumentsDirectory()).path;
  return CLMediaDB.getByTagId(
    databaseManager.db,
    tagID,
    pathPrefix: pathPrefix,
  );
});
