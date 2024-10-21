import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:store/store.dart';

import '../../db_service/models/store_updater.dart';
import '../../db_service/models/store_updter_ext_store.dart';
import '../../extensions/ext_cl_media.dart';
import '../models/cl_server.dart';
import '../models/media_change_tracker.dart';
import '../models/server.dart';
import '../models/server_upload_entity.dart';
import 'downloader.dart';

mixin MediaSyncMixIn {
  static void log(
    String message, {
    int level = 0,
    Object? error,
    StackTrace? stackTrace,
  }) {
    /* dev.log(
      message,
      level: level,
      error: error,
      stackTrace: stackTrace,
      name: 'Online Service | Server',
    ); */
  }

  Future<Map<String, dynamic>> updateCollectionId(
    Map<String, dynamic> map, {
    required StoreUpdater updater,
  }) async {
    if (map.containsKey('collectionLabel')) {
      map['collectionId'] ??=
          await updater.collectionIdFromLabel(map['collectionLabel'] as String);
    } else {
      throw Exception('collectionLabel is missing');
    }
    return map;
  }

  Future<void> updateServerResponse(
    CLMedia media,
    Map<String, dynamic> resMap, {
    required CLServer server,
    required StoreUpdater updater,
    required DownloaderNotifier downloader,
  }) async {
    final store = updater.store;
    final uploadedMedia = StoreExtCLMedia.mediaFromServerMap(
      media,
      await updateCollectionId(resMap, updater: updater),
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
    store.reloadStore();
    if (media.mediaFileName != uploadedMedia.mediaFileName) {
      await File(updater.mediaFileAbsolutePath(media)).deleteIfExists();
    }
    if (media.previewFileName != uploadedMedia.previewFileName) {
      await File(updater.previewFileAbsolutePath(media)).deleteIfExists();
    }
  }

  Future<void> _upload(
    CLMedia media, {
    required CLServer server,
    required StoreUpdater updater,
    required DownloaderNotifier downloader,
  }) async {
    log('id ${media.id}: upload');

    final store = updater.store;

    final collection =
        (await store.reader.getCollectionById(media.collectionId!))!;
    final entity0 = ServerUploadEntity(
      path: updater.mediaFileRelativePath(media),
      name: media.name,
      collectionLabel: collection.label,
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
        await updateServerResponse(
          media,
          resMap,
          server: server,
          updater: updater,
          downloader: downloader,
        );
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> _deleteLocal(
    CLMedia media, {
    required CLServer server,
    required StoreUpdater updater,
    required DownloaderNotifier downloader,
  }) async {
    log('ServerUID ${media.serverUID}: updateOnServer');

    await updater.permanentlyDeleteMediaMultipleById(
      {media.id!},
      shouldRefresh: false,
    );
  }

  Future<void> _download(
    CLMedia media, {
    required CLServer server,
    required StoreUpdater updater,
    required DownloaderNotifier downloader,
  }) async {
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

  Future<void> _updateLocal(
    CLMedia media, {
    required CLServer server,
    required StoreUpdater updater,
    required DownloaderNotifier downloader,
  }) async {
    log('ServerUID ${media.serverUID}: updateOnServer');

    await updater.upsertMedia(
      media,
      shouldRefresh: false,
    );
  }

  Future<void> _deleteOnServer(
    CLMedia media, {
    required CLServer server,
    required StoreUpdater updater,
    required DownloaderNotifier downloader,
  }) async {
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

  Future<void> _updateOnServer(
    CLMedia media, {
    required CLServer server,
    required StoreUpdater updater,
    required DownloaderNotifier downloader,
    bool uploadFile = false,
  }) async {
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
      await updateServerResponse(
        media,
        resMap,
        server: server,
        updater: updater,
        downloader: downloader,
      );
    }
  }

  Future<void> mediaSync(
    List<MediaChangeTracker> trackers, {
    required CLServer server,
    required StoreUpdater updater,
    required DownloaderNotifier downloader,
  }) async {
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
          await _upload(
            l!,
            server: server,
            updater: updater,
            downloader: downloader,
          );
        case ActionType.deleteLocal:
          await _deleteLocal(
            l!,
            server: server,
            updater: updater,
            downloader: downloader,
          );
        case ActionType.download:
          await _download(
            s!,
            server: server,
            updater: updater,
            downloader: downloader,
          );
        case ActionType.updateLocal:
          await _updateLocal(
            s!,
            server: server,
            updater: updater,
            downloader: downloader,
          );
        case ActionType.deleteOnServer:
          await _deleteOnServer(
            l!,
            server: server,
            updater: updater,
            downloader: downloader,
          );
        case ActionType.updateOnServer:
          final uploadFile = l!.md5String != s!.md5String;
          await _updateOnServer(
            l.updateContent(serverUID: () => s.serverUID!, isEdited: false),
            uploadFile: uploadFile,
            server: server,
            updater: updater,
            downloader: downloader,
          );
        case ActionType.markConflict:
          log('ServerUID ${s!.serverUID}: Conflict');
          throw UnimplementedError();
      }
    }
  }
}
