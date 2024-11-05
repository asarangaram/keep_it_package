import 'package:flutter/foundation.dart';
import 'package:store/store.dart';

import '../../../extensions/ext_cl_media.dart';
import '../media_change_tracker.dart';
import '../server.dart';
import 'sync_module.dart';

@immutable
class CollectionSyncModule extends SyncModule<Collection> {
  CollectionSyncModule(super.server, super.updater, super.downloader);
  Future<Map<String, dynamic>> updateCollectionId(
    Map<String, dynamic> map,
  ) async {
    if (map.containsKey('collectionLabel')) {
      map['collectionId'] ??= (await updater.collectionUpdater
              .getCollectionByLabel(map['collectionLabel'] as String))
          .id;
    } else {
      throw Exception('collectionLabel is missing');
    }
    return map;
  }

  Future<List<Map<String, dynamic>>> get collectionOnServerMap async {
    final serverItemsMap = await server.downloadCollectionInfo();
    return serverItemsMap;
  }

  Future<List<ChangeTracker>> analyse(
    List<Map<String, dynamic>> itemsOnServerMap,
    List<Collection> itemsOnDevice,
  ) async {
    final trackers = <ChangeTracker>[];
    log('items in local: ${itemsOnDevice.length}');
    log('items in Server: ${itemsOnServerMap.length}');
    for (final serverEntry in itemsOnServerMap) {
      final localEntry = itemsOnDevice
          .where(
            (e) =>
                e.serverUID == serverEntry['serverUID'] ||
                e.label == serverEntry['label'],
          )
          .firstOrNull;

      final tracker = ChangeTracker(
        current: localEntry,
        update:
            StoreExtCollection.collectionFromServerMap(localEntry, serverEntry),
      );

      if (!tracker.isActionNone) {
        trackers.add(tracker);
      }
      if (localEntry != null) {
        itemsOnDevice.remove(localEntry);
      }
    }

    // For remaining items
    for (final item in itemsOnDevice) {
      final tracker = ChangeTracker(current: item, update: null);
      if (!tracker.isActionNone) {
        trackers.add(tracker);
      }
    }
    return trackers;
  }

  @override
  Future<void> sync() async {
    final itemsOnServerMap = await collectionOnServerMap;
    final itemsOnDevice = await updater.store.reader.collectionOnDevice;

    final trackers = await analyse(itemsOnServerMap, itemsOnDevice);
    log(' ${trackers.length} items need sync');
    if (trackers.isEmpty) return;

    for (final (i, tracker) in trackers.indexed) {
      log('sync $i');
      final l = tracker.current as Collection?; // local
      final s = tracker.update as Collection?; // server
      switch (tracker.actionType) {
        case ActionType.none:
          throw Exception('should not have come for sync');
        case ActionType.upload:
          await upload(l!);

        case ActionType.deleteLocal:
          await deleteLocal(l!);
        case ActionType.download:
          await download(s!);
        case ActionType.updateLocal:
          await updateLocal(s!);
        case ActionType.deleteOnServer:
          await deleteOnServer(l!);
        case ActionType.updateOnServer:
          await updateOnServer(
            l!.copyWith(serverUID: () => s?.serverUID, isEdited: false),
          );
        case ActionType.markConflict:
          log('ServerUID ${s!.serverUID}: Conflict');
          throw UnimplementedError();
      }
    }
  }

  @override
  Future<void> deleteLocal(Collection item) async {
    final collection = item;
    log('ServerUID ${collection.serverUID}: deleteLocal');

    await updater.collectionUpdater.delete(
      collection.id!,
      shouldRefresh: false,
    );
  }

  @override
  Future<void> deleteOnServer(Collection item) async {
    final collection = item;
    log('ServerUID ${collection.serverUID}: deleteOnServer');
    try {
      if (collection.isDeleted != true) {
        throw Exception('delete is not marked correctly');
      }

      final resMap = await Server.upsertCollection(
        collection,
        server: server,
      );
      if (resMap != null) {
        if (resMap['isDeleted'] == 1 &&
            resMap['serverUID'] == collection.serverUID) {
          await updater.collectionUpdater.deletePermanently(
            collection.id!,
            shouldRefresh: false,
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> download(Collection item) async {
    final collection = item;
    log('ServerUID ${collection.serverUID}: download');

    await updater.collectionUpdater.upsert(
      collection,
      shouldRefresh: false,
    );
  }

  @override
  Future<void> updateLocal(Collection item) async {
    final collection = item;
    log('ServerUID ${collection.serverUID}: updateLocal');

    await updater.collectionUpdater.upsert(
      collection,
      shouldRefresh: false,
    );
  }

  @override
  Future<void> updateOnServer(Collection item) async {
    final collection = item;
    log('ServerUID ${collection.serverUID}: updateOnServer');

    final resMap = await Server.upsertCollection(
      collection,
      server: server,
    );
    if (resMap != null) {
      await updateServerResponse(collection, resMap);
    }
  }

  @override
  Future<void> updateServerResponse(
    Collection item,
    Map<String, dynamic> resMap,
  ) async {
    final collection = item;
    final uploadedCollection =
        StoreExtCollection.collectionFromServerMap(collection, resMap);
    await updater.collectionUpdater
        .upsert(uploadedCollection, shouldRefresh: false);
    return;
  }

  @override
  Future<void> upload(Collection item) async {
    final collection = item;
    log('id ${item.id}: upload collection');

    try {
      final resMap = await Server.upsertCollection(
        collection.copyWith(serverUID: () => null),
        server: server,
      );
      if (resMap != null) {
        await updateServerResponse(collection, resMap);
      }
    } catch (e) {
      /** FIXME, when server fails */
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
