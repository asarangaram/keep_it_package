import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:store/store.dart';

import '../../../extensions/ext_cl_media.dart';
import '../media_change_tracker.dart';
import '../server.dart';
import '../server_upload_entity.dart';
import 'sync_module.dart';

@immutable
class MediaSyncModule extends SyncModule<CLMedia> {
  MediaSyncModule(
    super.server,
    super.updater,
    super.downloader,
    this.collectionsToSync,
  );
  final List<Collection> collectionsToSync;
  Future<List<Map<String, dynamic>>> get mediaOnServerMap async {
    final collectionLabels = collectionsToSync.map((e) => e.label);
    final serverItemsMap = await server.downloadMediaInfo();
    serverItemsMap.removeWhere(
      (map) => !collectionLabels.contains(map['collectionLabel']),
    );
    final list = <Map<String, dynamic>>[];
    for (final serverEntry in serverItemsMap) {
      final label = serverEntry['collectionLabel'] as String?;
      if (label == null) {
        throw Exception('collectionLabel is missing');
      }

      final collection =
          collectionsToSync.where((e) => e.label == label).firstOrNull;
      if (collection == null) {
        throw Exception('Collection not found for the provided label');
      }
      // update collectionId
      serverEntry['collectionId'] = collection.id;
      list.add(serverEntry);
    }
    return list;
  }

  Future<List<ChangeTracker>> analyse(
    List<Map<String, dynamic>> itemsOnServerMap,
    List<CLMedia> itemsOnDevice,
  ) async {
    final trackers = <ChangeTracker>[];
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

      final tracker = ChangeTracker(
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
    final itemsOnServerMap = await mediaOnServerMap;
    final itemsOnDevice = await updater.store.reader.mediaOnDevice;

    final trackers = await analyse(itemsOnServerMap, itemsOnDevice);
    if (trackers.isEmpty) return;
    log(' ${trackers.length} items need sync');
    for (final (i, tracker) in trackers.indexed) {
      log('sync $i');
      final l = tracker.current as CLMedia?; // local
      final s = tracker.update as CLMedia?; // server
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
    unawaited(downloadMediaFiles());
  }

  Future<void> downloadMediaFiles() async {
    log('triggerred downloadMediaFiles');
    final mediaOnDevice = await updater.store.reader.mediaOnDevice;
    final syncedCollections =
        collectionsToSync.where((e) => e.haveItOffline).toList();

    for (final m in mediaOnDevice) {
      final collection =
          syncedCollections.where((e) => e.id == m.collectionId).firstOrNull;

      await downloadMediaFile(
        m,
        isCollectionSynced: collection != null,
      );
    }
    updater.store.reloadStore();
  }

  @override
  Future<void> deleteLocal(CLMedia item) async {
    final media = item;
    log('ServerUID ${media.serverUID}: deleteLocal');

    await updater.mediaUpdater.deletePermanently(
      media.id!,
      shouldRefresh: false,
    );
  }

  @override
  Future<void> deleteOnServer(CLMedia item) async {
    final media = item;
    log('ServerUID ${media.serverUID}: deleteOnServer');
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
      );
      if (resMap != null) {
        if (resMap['isDeleted'] == 1 &&
            resMap['serverUID'] == media.serverUID) {
          await updater.mediaUpdater.deletePermanently(
            media.id!,
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

    await updater.mediaUpdater
        .upsert(
      media,
      shouldRefresh: false,
    )
        .then((_) {
      downloadPreview(media);
    });
    /* final updated =  if (updated != null) {
      await downloadFiles(updated);
    } */
  }

  void downloadPreview(CLMedia media) {
    final fileMissing =
        !File(updater.mediaUpdater.fileAbsolutePath(media)).existsSync();
    if (media.isPreviewWaitingForDownload || fileMissing) {
      Server.downloadPreviewFile(
        media.serverUID!,
        updater.mediaUpdater.previewRelativePath(media),
        server: server,
        downloader: downloader,
        mediaBaseDirectory: BaseDirectory.applicationSupport,
      ).then((previewLog) {
        updater.store.updateMediaFromMap({
          'id': media.id,
          'isPreviewCached': previewLog == null,
          'previewLog': previewLog == 'cancelled' ? null : previewLog,
        }).then((mediaInDB) {
          if (mediaInDB != null) {
            log('preview download status '
                'for ${media.id}: ${previewLog == null}');
          } else {
            log('preview update failed for ${media.id} ');
          }
        });
      });
    }
  }

  Future<void> downloadMediaFile(
    CLMedia media, {
    required bool isCollectionSynced,
  }) async {
    log('<downloadMediaFile> trigger download for media ${media.id}');
    final file = File(updater.mediaUpdater.fileAbsolutePath(media));
    if (file.existsSync()) {
      final needDownload = !media.isMediaCached &&
          media.mediaLog == null &&
          (media.haveItOffline ?? isCollectionSynced);
      if (needDownload) {
        await updater.store.updateMediaFromMap({
          'id': media.id,
          'isMediaCached': true,
          'mediaLog': null,
        });
      }
      updater.store.reloadStore();

      return;
    }
    final needDownload = !media.isMediaCached &&
        media.mediaLog == null &&
        (switch (media.haveItOffline) {
          null => isCollectionSynced,
          false => false,
          true => true
        });

    if (!needDownload) {
      log('<downloadMediaFile>  download not required '
          'for media ${media.id}');
      return;
    }
    return Server.downloadMediaFile(
      media.serverUID!,
      updater.mediaUpdater.fileRelativePath(media),
      server: server,
      downloader: downloader,
      mediaBaseDirectory: BaseDirectory.applicationSupport,
    ).then<void>((mediaLog) {
      log('<downloadMediaFile>  download completed '
          'for media ${media.id} with status ${mediaLog == null}');
      updater.store.updateMediaFromMap({
        'id': media.id,
        'isMediaCached': mediaLog == null ? 1 : 0,
        'mediaLog': mediaLog == 'cancelled' ? null : mediaLog,
      }).then((mediaInDB) {
        if (mediaInDB != null) {
          log('preview download status '
              'for ${media.id}: ${mediaLog == null}');
        } else {
          log('preview update failed for ${media.id} ');
        }
        log('<downloadMediaFile>  media in DB updated '
            'for media ${media.id} with status ${mediaLog == null}');
        updater.store.reloadStore();
      });
      return;
    });
  }

  @override
  Future<void> updateLocal(CLMedia item) async {
    final media = item;
    log('ServerUID ${media.serverUID}: updateLocal');

    await updater.mediaUpdater.upsert(
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
      path: uploadFile ? updater.mediaUpdater.fileRelativePath(media) : null,
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
    final collection = collectionsToSync
        .where((e) => e.label == resMap['collectionLabel'])
        .firstOrNull;
    if (collection == null) {
      throw Exception('Collection not found for the provided label');
    }
    resMap['collectionId'] = collection.id;

    final media = item;
    final uploadedMedia = StoreExtCLMedia.mediaFromServerMap(media, resMap);

    await updater.mediaUpdater
        .upsert(uploadedMedia, shouldRefresh: false)
        .then((_) {
      downloadPreview(media);
    });

    /*final updated =  if (updated != null) {
      await downloadFiles(updated);
      store.reloadStore(); // check if this is really needed here
      if (media.mediaFileName != updated.mediaFileName) {
        await File(updater.mediaUpdater.fileAbsolutePath(media))
            .deleteIfExists();
      }
      if (media.previewFileName != updated.previewFileName) {
        await File(updater.mediaUpdater.previewAbsolutePath(media))
            .deleteIfExists();
      }
    } */
  }

  @override
  Future<void> upload(CLMedia item) async {
    final media = item.updateContent(
      isEdited: false,
      serverUID: () => null,
    );
    log('id ${media.id}: upload');

    final store = updater.store;

    final collection =
        await store.reader.getCollectionById(media.collectionId!);
    final entity0 = ServerUploadEntity(
      path: updater.mediaUpdater.fileRelativePath(media),
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
      );
      if (resMap != null) {
        await updateServerResponse(media, resMap);
      }
    } catch (e) {
      /** FIXME, when server fails */
      if (kDebugMode) {
        print(e);
      }
    }
  }
}
