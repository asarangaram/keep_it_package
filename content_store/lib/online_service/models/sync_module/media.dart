import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:content_store/extensions/list_ext.dart';

import 'package:flutter/foundation.dart';
import 'package:store/store.dart';

import '../../../db_service/models/store_updter_ext_store.dart';
import '../../../extensions/ext_cl_media.dart';
import '../media_change_tracker.dart';
import '../server.dart';
import '../server_upload_entity.dart';
import 'sync_module.dart';

@immutable
class MediaSyncModule extends SyncModule<CLMedia> {
  MediaSyncModule(super.server, super.updater, super.downloader);
  Future<Map<String, dynamic>> updateCollectionId(
    Map<String, dynamic> map,
  ) async {
    if (map.containsKey('collectionLabel')) {
      map['collectionId'] ??=
          await updater.collectionIdFromLabel(map['collectionLabel'] as String);
    } else {
      throw Exception('collectionLabel is missing');
    }
    return map;
  }

  Future<List<CLMedia>> mediaOnDevice(int? collectionID) async {
    final q = store.reader.getQuery<CLMedia>(DBQueries.mediaOnDevice);
    return (await store.reader.readMultiple(q)).nonNullableList;
  }

  Future<List<Map<String, dynamic>>> mediaOnServerMap(int? collectionID) async {
    final serverItemsMap = await server.downloadMediaInfo();
    if (collectionID == null) {
    } else {}
    for (final serverEntry in serverItemsMap) {
      /// There are scenarios when the collections are not synced
      /// fully, we may end up creating one. However, other details for
      /// the newly created collection is not available at this stage, and
      /// we may need to fetch from server if needed. [KNOWN_ISSUE]
      await updateCollectionId(serverEntry);
    }
    return serverItemsMap;
  }

  Future<List<ChangeTracker<CLMedia>>> analyse(
    List<Map<String, dynamic>> itemsOnServerMap,
    List<CLMedia> itemsOnDevice,
  ) async {
    final trackers = <MediaChangeTracker>[];
    log('items in local: ${itemsOnDevice.length}');
    log('items in Server: ${itemsOnServerMap.length}');
    for (final serverEntry in itemsOnServerMap) {
      final localEntry = itemsOnDevice
          .where(
            (e) =>
                e.serverUID == serverEntry['serverUID'] ||
                e.md5String == serverEntry['md5String'],
          )
          .firstOrNull;

      final tracker = MediaChangeTracker(
        current: localEntry,
        update: StoreExtCLMedia.mediaFromServerMap(localEntry, serverEntry),
      );

      if (!tracker.isActionNone) {
        trackers.add(tracker);
      }
      if (localEntry != null) {
        itemsOnDevice.remove(localEntry);
      }
    }
    // For remaining items
    trackers.addAll(
      itemsOnDevice.map((e) => MediaChangeTracker(current: e, update: null)),
    );
    return trackers;
  }

  @override
  Future<void> sync(
    List<Map<String, dynamic>> itemsOnServerMap,
    List<CLMedia> itemsOnDevice,
  ) async {
    final trackers = await analyse(itemsOnServerMap, itemsOnDevice);
    if (trackers.isEmpty) return;
    log(' ${trackers.length} items need sync');
    for (final (i, tracker) in trackers.indexed) {
      log('sync $i');
      final l = tracker.current; // local
      final s = tracker.update; // server
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
          final uploadFile = l!.md5String != s!.md5String;
          await updateOnServer(
            l.updateContent(serverUID: () => s.serverUID, isEdited: false),
            uploadFile: uploadFile,
          );
        case ActionType.markConflict:
          log('ServerUID ${s!.serverUID}: Conflict');
          throw UnimplementedError();
      }
    }
  }

  @override
  Future<void> deleteLocal(CLMedia item) async {
    final media = item;
    log('ServerUID ${media.serverUID}: updateOnServer');

    await updater.permanentlyDeleteMediaMultipleById(
      {media.id!},
      shouldRefresh: false,
    );
  }

  @override
  Future<void> deleteOnServer(CLMedia item) async {
    final media = item;
    log('ServerUID ${media.serverUID}: updateOnServer');
    try {
      if (media.isDeleted != true) {
        throw Exception('delete is not marked correctly');
      }
      final entity0 = ServerUploadEntity.update(
        serverUID: media.serverUID!,
        isDeleted: media.isDeleted,
        updatedDate: media.updatedDate,
      );
      final resMap = await Server.upsertMedia(
        entity0,
        server: server,
        downloader: downloader,
        mediaBaseDirectory: BaseDirectory.applicationSupport,
      );
      if (resMap != null) {
        if (resMap['isDeleted'] == 1 &&
            resMap['serverUID'] == media.serverUID) {
          await updater.permanentlyDeleteMediaMultipleById(
            {media.id!},
            shouldRefresh: false,
          );
        }
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> download(CLMedia item) async {
    final media = item;
    log('ServerUID ${media.serverUID}: updateOnServer');

    await updater.upsertMedia(
      media,
      shouldRefresh: false,
    );
    final mediaLog = await Server.downloadMediaFile(
      media.serverUID!,
      updater.mediaFileRelativePath(media),
      server: server,
      downloader: downloader,
      mediaBaseDirectory: BaseDirectory.applicationSupport,
    );

    final previewLog = await Server.downloadPreviewFile(
      media.serverUID!,
      updater.previewFileRelativePath(media),
      server: server,
      downloader: downloader,
      mediaBaseDirectory: BaseDirectory.applicationSupport,
    );
    await updater.upsertMedia(
      media.updateStatus(
        isMediaCached: () => mediaLog == null,
        mediaLog: () => mediaLog == 'cancelled' ? null : mediaLog,
        isMediaOriginal: () => false,
        isPreviewCached: () => previewLog == null,
        previewLog: () => previewLog == 'cancelled' ? null : previewLog,
      ),
      shouldRefresh: false,
    );
  }

  @override
  Future<void> updateLocal(CLMedia item) async {
    final media = item;
    log('ServerUID ${media.serverUID}: updateOnServer');

    await updater.upsertMedia(
      media,
      shouldRefresh: false,
    );
  }

  @override
  Future<void> updateOnServer(CLMedia item, {bool uploadFile = false}) async {
    final media = item;
    log('ServerUID ${media.serverUID}: updateOnServer');

    final store = updater.store;

    final collection =
        await store.reader.getCollectionById(media.collectionId!);
    final entity0 = ServerUploadEntity.update(
      serverUID: media.serverUID!,
      path: uploadFile ? updater.mediaFileRelativePath(media) : null,
      name: media.name,
      collectionLabel: collection!.label,
      updatedDate: media.updatedDate,
      isDeleted: media.isDeleted,
      originalDate: media.originalDate,
      ref: media.ref,
    );
    final resMap = await Server.upsertMedia(
      entity0,
      server: server,
      downloader: downloader,
      mediaBaseDirectory: BaseDirectory.applicationSupport,
    );
    if (resMap != null) {
      await updateServerResponse(media, resMap);
    }
  }

  @override
  Future<void> updateServerResponse(
    CLMedia item,
    Map<String, dynamic> resMap,
  ) async {
    final media = item;
    final uploadedMedia = StoreExtCLMedia.mediaFromServerMap(
      media,
      await updateCollectionId(resMap),
    );

    await updater.upsertMedia(uploadedMedia, shouldRefresh: false);

    final mediaLog = await Server.downloadMediaFile(
      uploadedMedia.serverUID!,
      updater.mediaFileRelativePath(uploadedMedia),
      server: server,
      downloader: downloader,
      mediaBaseDirectory: BaseDirectory.applicationSupport,
    );

    final previewLog = await Server.downloadPreviewFile(
      uploadedMedia.serverUID!,
      updater.previewFileRelativePath(uploadedMedia),
      server: server,
      downloader: downloader,
      mediaBaseDirectory: BaseDirectory.applicationSupport,
    );
    await updater.upsertMedia(
      uploadedMedia.updateStatus(
        isMediaCached: () => mediaLog == null,
        mediaLog: () => mediaLog == 'cancelled' ? null : mediaLog,
        isMediaOriginal: () => false,
        isPreviewCached: () => previewLog == null,
        previewLog: () => previewLog == 'cancelled' ? null : previewLog,
      ),
      shouldRefresh: false,
    );
    store.reloadStore(); // check if this is really needed here
    if (media.mediaFileName != uploadedMedia.mediaFileName) {
      await File(updater.mediaFileAbsolutePath(media)).deleteIfExists();
    }
    if (media.previewFileName != uploadedMedia.previewFileName) {
      await File(updater.previewFileAbsolutePath(media)).deleteIfExists();
    }
  }

  @override
  Future<void> upload(CLMedia item) async {
    final media = item;
    log('id ${media.id}: upload');

    final store = updater.store;

    final collection =
        await store.reader.getCollectionById(media.collectionId!);
    final entity0 = ServerUploadEntity(
      path: updater.mediaFileRelativePath(media),
      name: media.name,
      collectionLabel: collection!.label,
      createdDate: media.createdDate,
      isDeleted: media.isDeleted ?? false,
      originalDate: media.originalDate,
      ref: media.ref,
    );

    try {
      final resMap = await Server.upsertMedia(
        entity0,
        server: server,
        downloader: downloader,
        mediaBaseDirectory: BaseDirectory.applicationSupport,
      );
      if (resMap != null) {
        await updateServerResponse(media, resMap);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
