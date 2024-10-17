import 'dart:async';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:content_store/db_service/models/store_updter_ext_store.dart';
import 'package:content_store/extensions/list_ext.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:store/store.dart';

import '../../db_service/models/store_updater.dart';
import '../../db_service/providers/store_updater.dart';
import '../../extensions/ext_cl_media.dart';
import '../models/cl_server.dart';
import '../models/media_change_tracker.dart';
import '../models/server.dart';
import '../models/server_upload_entity.dart';
import 'downloader.dart';

class ServerNotifier extends StateNotifier<Server> {
  ServerNotifier(this.storeUpdater, this.downloader) : super(const Server()) {
    _initialize();
  }

  Timer? timer;
  Future<StoreUpdater> storeUpdater;
  DownloaderNotifier downloader;

  Future<void> _initialize() async {
    final prefs = await SharedPreferences.getInstance();
    final myServerJSON = prefs.getString('myServer');
    if (myServerJSON != null) {
      final identity = CLServer.fromJson(myServerJSON);
      log('Server found from history. $identity');
      final workingOffline = prefs.getBool('workingOffline');

      await setState(
        state.copyWith(
          identity: () => identity,
          workingOffline: workingOffline,
        ),
      );
    }

    // Read Workoffline from sharedPReference and update
  }

  Server get currState => state;

  set currState(Server val) {
    state = val;
    log(state.toString());
  }

  Future<void> setState(Server server) async {
    currState = server;
    final prefs = await SharedPreferences.getInstance();
    if (state.identity != null) {
      await prefs.setString('myServer', state.identity!.toJson());
    } else {
      await prefs.remove('myServer');
    }
    await prefs.setBool('workingOffline', state.workingOffline);
    if (state.isRegistered) {
      final isOnline = (await server.identity?.hasConnection()) ?? false;
      currState = state.copyWith(isOffline: !isOnline);
      timer?.cancel();
      timer = Timer.periodic(const Duration(seconds: 30), (Timer timer) {
        if (state.isRegistered) {
          server.identity!.hasConnection().then((isOnline) {
            currState = state.copyWith(isOffline: !isOnline);
          });
        } else {
          timer.cancel();
        }
      });
    } else {
      timer?.cancel();
      timer = null;
    }
  }

  void register(CLServer candidate) {
    if (state.isRegistered) {
      if (state.identity != candidate) {
        log("can't register ($candidate) as "
            'another server( ${state.identity}) is registered');
      }
      return;
    }
    setState(state.copyWith(identity: () => candidate))
        .then((_) => log('server registered $state'));
  }

  void deregister() {
    if (state.isRegistered) {
      setState(state.copyWith(identity: () => null));
    }
  }

  void goOnline() => setState(state.copyWith(workingOffline: false));

  void workOffline() => setState(state.copyWith(workingOffline: true));

  void sync() {
    if (state.isSyncing) {
      log('server is already syncing. ignoring duplicate request');
      return;
    }
    if (!state.canSync) {
      log("server can't sync");
      return;
    }
    log('sync starting');
    setState(state.copyWith(isSyncing: true)).then(
      (_) => _sync(state.identity!).then((_) {
        setState(state.copyWith(isSyncing: false));
        log('sync Completed');
      }),
    );
  }

  void checkStatus() {
    if (state.isRegistered) {
      state.identity!.hasConnection().then((isOnline) {
        currState = state.copyWith(isOffline: !isOnline);
      });
    }
    return;
  }

  Future<void> updateServerResponse(
    CLServer server,
    CLMedia media,
    Map<String, dynamic> resMap,
  ) async {
    final updater = await storeUpdater;
    final store = (await storeUpdater).store;
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
    store.reloadStore();
    if (media.mediaFileName != uploadedMedia.mediaFileName) {
      await File(updater.mediaFileAbsolutePath(media)).deleteIfExists();
    }
    if (media.previewFileName != uploadedMedia.previewFileName) {
      await File(updater.previewFileAbsolutePath(media)).deleteIfExists();
    }
  }

  Future<void> upload(CLServer server, CLMedia media) async {
    final updater = await storeUpdater;
    log('id ${media.id}: upload');

    final store = (await storeUpdater).store;

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
        await updateServerResponse(server, media, resMap);
      }
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
    }
  }

  Future<void> deleteLocal(CLServer server, CLMedia media) async {
    log('ServerUID ${media.serverUID}: updateOnServer');

    final updater = await storeUpdater;
    await updater.permanentlyDeleteMediaMultipleById(
      {media.id!},
      shouldRefresh: false,
    );
  }

  Future<void> download(CLServer server, CLMedia media) async {
    log('ServerUID ${media.serverUID}: updateOnServer');

    final updater = await storeUpdater;
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

  Future<void> updateLocal(CLServer server, CLMedia media) async {
    log('ServerUID ${media.serverUID}: updateOnServer');

    final updater = await storeUpdater;
    await updater.upsertMedia(
      media,
      shouldRefresh: false,
    );
  }

  Future<void> deleteOnServer(CLServer server, CLMedia media) async {
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
          final updater = await storeUpdater;
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

  Future<Map<String, dynamic>> updateCollectionId(
    Map<String, dynamic> map,
  ) async {
    final store = (await storeUpdater).store;
    final updater = await storeUpdater;
    if (map.containsKey('collectionLabel')) {
      final label = map['collectionLabel'] as String;
      final collection = await store.reader.getCollectionByLabel(label) ??
          (await updater.upsertCollection(
            Collection(label: label),
            shouldRefresh: false,
          ));
      map['collectionId'] = collection.id;
    } else {
      throw Exception('collectionLabel is missing');
    }
    return map;
  }

  Future<void> updateOnServer(
    CLServer server,
    CLMedia media, {
    bool uploadFile = false,
  }) async {
    log('ServerUID ${media.serverUID}: updateOnServer');
    final updater = await storeUpdater;

    final store = (await storeUpdater).store;

    final collection =
        (await store.reader.getCollectionById(media.collectionId!))!;
    final entity0 = ServerUploadEntity.update(
      serverUID: media.serverUID!,
      path: uploadFile ? updater.mediaFileRelativePath(media) : null,
      name: media.name,
      collectionLabel: collection.label,
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
      await updateServerResponse(server, media, resMap);
    }
  }

  Future<void> _sync(CLServer server) async {
    final trackers = await analyse(await state.identity!.downloadMediaInfo());

    log(' ${trackers.length} items need sync');
    if (trackers.isEmpty) return;

    for (final (i, tracker) in trackers.indexed) {
      log('sync $i');
      final l = tracker.current; // local
      final s = tracker.update; // server
      switch (tracker.actionType) {
        case ActionType.none:
          throw Exception('should not have come for sync');
        case ActionType.upload:
          await upload(server, l!);
        case ActionType.deleteLocal:
          await deleteLocal(server, l!);
        case ActionType.download:
          await download(server, s!);
        case ActionType.updateLocal:
          await updateLocal(server, s!);
        case ActionType.deleteOnServer:
          await deleteOnServer(server, l!);
        case ActionType.updateOnServer:
          final uploadFile = l!.md5String != s!.md5String;
          await updateOnServer(
            server,
            l.updateContent(serverUID: () => s.serverUID!, isEdited: false),
            uploadFile: uploadFile,
          );
        case ActionType.markConflict:
          log('ServerUID ${s!.serverUID}: Conflict');
      }
    }
    (await storeUpdater).store.reloadStore();
  }

  Future<List<MediaChangeTracker>> analyse(
    List<Map<String, dynamic>> mapList,
  ) async {
    final store = (await storeUpdater).store;
    final q = store.reader.getQuery<CLMedia>(DBQueries.mediaSyncQuery);
    final localItems = (await store.reader.readMultiple(q)).nonNullableList;
    final trackers = <MediaChangeTracker>[];
    log('items in local: ${localItems.length}');
    log('items in Server: ${mapList.length}');
    for (final serverEntry in mapList) {
      final localEntry = localItems
          .where(
            (e) =>
                e.serverUID == serverEntry['serverUID'] ||
                e.md5String == serverEntry['md5String'],
          )
          .firstOrNull;

      /// There are scenarios when the collections are not synced
      /// fully, we may end up creating one. However, other details for
      /// the newly created collection is not available at this stage, and
      /// we may need to fetch from server if needed. [KNOWN_ISSUE]
      if (serverEntry.containsKey('collectionLabel')) {
        final label = serverEntry['collectionLabel'] as String;
        final collection = await store.reader.getCollectionByLabel(label) ??
            (await (await storeUpdater).upsertCollection(
              Collection(label: label),
              shouldRefresh: false,
            ));
        serverEntry['collectionId'] = collection.id;
      } else {
        throw Exception('collectionLabel is missing');
      }

      final tracker = MediaChangeTracker(
        current: localEntry,
        update: StoreExtCLMedia.mediaFromServerMap(localEntry, serverEntry),
      );

      if (!tracker.isActionNone) {
        trackers.add(tracker);
      }
      if (localEntry != null) {
        localItems.remove(localEntry);
      }
    }
    // For remaining items
    trackers.addAll(
      localItems.map((e) => MediaChangeTracker(current: e, update: null)),
    );
    return trackers;
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  void log(
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
}

final serverProvider = StateNotifierProvider<ServerNotifier, Server>((ref) {
  final storeUpdater = ref.watch(storeUpdaterProvider.future);
  final downloaderNotifier = ref.watch(downloaderProvider.notifier);
  final notifier = ServerNotifier(storeUpdater, downloaderNotifier);
  ref.listenSelf((prev, curr) {
    if (curr.canSync && !(prev?.canSync ?? false)) {
      notifier.sync();
    }
  });
  return notifier;
});
