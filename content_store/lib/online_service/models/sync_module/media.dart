import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:store/store.dart';

import '../../../db_service/models/media_updater.dart';
import '../../../extensions/ext_cl_media.dart';
import '../../../extensions/ext_cldirectories.dart';
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
  @override
  String get moduleName => 'Media Sync';
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
      try {
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
      } catch (e) {
        if (kDebugMode) {
          print('skipping as error occured $e');
        }
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
    //print(itemsOnServerMap);
    //print(itemsOnDevice);

    final trackers = await analyse(itemsOnServerMap, itemsOnDevice);
    log(' ${trackers.length} items need sync');
    if (trackers.isNotEmpty) {
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
    }
    await downloadMediaFiles();
  }

  Future<void> downloadMediaFiles() async {
    log('triggerred downloadMediaFiles');
    final mediaOnDevice = await updater.store.reader.mediaOnDevice;
    final syncedCollections = collectionsToSync
        .where((e) => e.haveItOffline && !e.isDeleted)
        .toList();

    for (final m in mediaOnDevice) {
      final collection =
          syncedCollections.where((e) => e.id == m.collectionId).firstOrNull;

      await downloadMediaFile(
        m,
        isCollectionSynced: collection != null,
      );
    }
    //updater.store.reloadStore();
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
          await updater.mediaUpdater
              .upsert(media.updateStatus(isMediaCached: () => false));
          await File(updater.directories.getMediaAbsolutePath(media))
              .deleteIfExists();

          /* 
          don't delete the entry, only delete the file
          await updater.mediaUpdater.deletePermanently(
            media.id!,
            shouldRefresh: false,
          ); */
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

    final mediaInDB = await updater.mediaUpdater.upsert(
      media,
      shouldRefresh: false,
    );
    if (mediaInDB != null) {
      await previewHandler(mediaInDB);
    }
  }

  Future<String?> downloadOrGenerate(CLMedia media) async {
    try {
      if (media.hasServerUID) {
        // download
        return await Server.downloadPreviewFile(
          media.serverUID!,
          updater.mediaUpdater.previewRelativePath(media),
          server: server,
          downloader: downloader,
          mediaBaseDirectory: BaseDirectory.applicationSupport,
        );
      } else {
        // generate
        final currentMediaPath =
            updater.directories.getMediaAbsolutePath(media);
        final currentPreviewPath =
            updater.directories.getPreviewAbsolutePath(media);
        return MediaUpdater.generatePreview(
          inputFile: currentMediaPath,
          outputFile: currentPreviewPath,
          type: media.type,
        );
      }
    } catch (e) {
      /**/
    }
    return null;
  }

  Future<void> previewHandler(CLMedia media) async {
    await _previewHandler(
      isPreviewCached: media.isPreviewCached,
      previousPreviewLog: media.previewLog,
      previewFile: updater.directories.getPreviewAbsolutePath(media),
      onGetPreview: () => downloadOrGenerate(media),
      onUpdatePreviewStatus: ({
        required bool isPreviewCached,
        String? previewLog,
      }) async =>
          updater.store.updateMediaFromMap({
        'id': media.id,
        'isPreviewCached': isPreviewCached,
        'previewLog': previewLog,
      }),
      infoLogger: (info) => log('<downloadPreview> [${media.id}] $info'),
    );
  }

  static Future<bool> _previewHandler({
    required bool isPreviewCached,
    required String previewFile,
    required Future<String?> Function() onGetPreview,
    required Future<CLMedia?> Function({
      required bool isPreviewCached,
      String? previewLog,
    }) onUpdatePreviewStatus,
    required String? previousPreviewLog,
    void Function(String info)? infoLogger,
  }) async {
    infoLogger?.call('trigger download for preview ');
    final previewFileExists = File(previewFile).existsSync();

    if (previewFileExists && isPreviewCached) {
      infoLogger?.call('Valid preview. Nothing to do');
      return true;
    }
    // if error is marked, we can't proceed.

    final String? previewLog;
    if (!previewFileExists) {
      if (previousPreviewLog == null) {
        infoLogger?.call('Missing preview file. Try generate or download');
        previewLog = await onGetPreview();
      } else {
        infoLogger?.call('Preview generation failed. Check error');
        return false;
      }
    } else {
      infoLogger?.call('Found preview file. Marking as exists');
      previewLog = null;
    }
    final mediaInDB = await onUpdatePreviewStatus(
      isPreviewCached: previewLog == null,
      previewLog: previewLog,
    );
    return mediaInDB != null;
  }

  Future<void> downloadMediaFile(
    CLMedia media, {
    required bool isCollectionSynced,
  }) async {
    /* log('<downloadMediaFile> trigger download for media ${media.id}'); */
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
      //updater.store.reloadStore();

      return;
    }
    var needDownload = !media.isMediaCached &&
        media.mediaLog == null &&
        (switch (media.haveItOffline) {
          null => switch (media.type) {
              CLMediaType.image => isCollectionSynced,
              _ => false
            },
          false => false,
          true => true
        });
    //isCollectionSynced
    needDownload = needDownload && !(media.isDeleted ?? false);

    if (!needDownload) {
      /* log('<downloadMediaFile>  download not required '
          'for media ${media.id}'); */

      return;
    }
    final mediaLog = await Server.downloadMediaFile(
      media.serverUID!,
      updater.mediaUpdater.fileRelativePath(media),
      server: server,
      downloader: downloader,
      mediaBaseDirectory: BaseDirectory.applicationSupport,
    );
    /* log('media download status '
        'for ${media.id}: ${mediaLog == null}'); */
    final mediaInDB = await updater.store.updateMediaFromMap({
      'id': media.id,
      'isMediaCached': mediaLog == null ? 1 : 0,
      'mediaLog': mediaLog == 'cancelled' ? null : mediaLog,
    });
    if (mediaInDB != null) {
      /* log('<downloadMediaFile>  media in DB updated '
          'for media ${media.id} with status ${mediaLog == null}'); */
    } else {
      /* log('preview update failed for ${media.id} '); */
    }
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

    final mediaInDB =
        await updater.mediaUpdater.upsert(uploadedMedia, shouldRefresh: false);
    if (mediaInDB != null) {
      await previewHandler(mediaInDB);
    }

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
      if (kDebugMode) {
        print(e);
      }
      throw Error(); // TEST_REQUIRED_TO_FIX
    }
  }
}
