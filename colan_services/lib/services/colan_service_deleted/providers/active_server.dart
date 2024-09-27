// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:async';
import 'dart:developer' as dev;

import 'package:colan_services/colan_services.dart';
import 'package:colan_services/internal/extensions/ext_store.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:meta/meta.dart';
import 'package:store/store.dart';

import '../../storage_service/models/file_system/models/cl_directories.dart';
import '../../storage_service/providers/directories.dart';
import '../models/cl_server.dart';
import '../models/downloader.dart';
import '../models/media_downloader.dart';
import '../models/server_status.dart';
import 'downloader_provider.dart';
import 'online_status.dart';
import 'registerred_server.dart';
import 'working_offline.dart';

class ActiveServerNotifier extends StateNotifier<ActiveServer> {
  ActiveServerNotifier({
    required this.ref,
    required this.directoriesFuture,
    required this.downloader,
  }) : super(const ActiveServer()) {
    _initialize();
  }
  final Ref ref;
  final Future<CLDirectories> directoriesFuture;
  // final Future<Store> storeFuture;

  final Downloader downloader;
  MediaDownloader? mediaDownloader;

  final runningTasks = <TaskCompleter>[];

  void log(
    String message, {
    int level = 0,
    Object? error,
    StackTrace? stackTrace,
  }) {
    dev.log(
      message,
      level: level,
      error: error,
      stackTrace: stackTrace,
      name: 'Online Service: Active Server',
    );
  }

  Future<void> _initialize() async {
    if (storeCache == null) return;
    if (state.server == null) return;
    mediaDownloader = MediaDownloader(
      downloader: downloader,
      server: state.server!,
      directories: await directoriesFuture,
      onDone: (map) async {
        //  log('download completed ${map["id"]}');
        await storeCache!.updateMediaFromMap(map);
      },
    );
    log('Media Downloader initialized for server $state');

    unawaited(sync());
  }

  Future<bool?> sync() async {
    if (storeCache == null) return null;
    if (server == null) return null;

    if (!state) {
      state = true;
      {
        // Upload logic here
        unawaited(
          server!.downloadMediaInfo().then((mapList) async {
            log('Found ${mapList.length} items in the server');
            final updates = await storeCache!.analyseChanges(
              mapList,
              createCollectionIfMissing: storeCache!.createCollectionIfMissing,
            );
            final result = await updateChanges(updates);

            if (result && mediaDownloader != null) {
              await downloadFiles(mediaDownloader!);
              if (mounted) {
                state = false;
              }
            } else {
              log('Sync ignored; either its not required or '
                  ' downloader not available');
              if (mounted) {
                state = false;
              }
            }
          }),
        );
        return true;
      }
    }
    return false;
  }

  Future<bool> insertMediaOnServer(Set<CLMedia> mediaSet) async {
    if (storeCache == null) return false;
    log('trigger upload for ${mediaSet.length} new media');
    final currentTasks = <TaskCompleter>[];
    for (final media in mediaSet) {
      if (media.collectionId != null) {
        final collection = storeCache!.getCollectionById(media.collectionId);
        final instance = await mediaDownloader!.uploadMedia(
          media,
          'upload',
          fields: {'collectionLabel': collection!.label},
        );
        runningTasks.add(instance);
        currentTasks.add(instance);
      }
    }
    await Future.wait(currentTasks.map((e) => e.completer.future));
    runningTasks.removeWhere((e) => e.completer.isCompleted);
    return false;
  }

  Future<bool> updateMediaOnServer(Set<TrackedMedia> mediaSet) async {
    return false;
  }

  Future<bool> deleteMediaByIdOnServer(Set<CLMedia> mediaSet) async {
    return false;
  }

  Future<bool> updateChanges(MediaUpdatesFromServer updates) async {
    if (storeCache == null) return false;
    var result = true;

    if (updates.deletedOnServer.isNotEmpty) {
      result = await storeCache!.permanentlyDeleteMediaMultiple(
        updates.deletedOnServer.map((e) => e.id!).toSet(),
      );
    }
    final upserts = [...updates.updatedOnServer, ...updates.newOnServer];
    if (upserts.isNotEmpty) {
      try {
        await storeCache!.updateMediaMultiple(
          [...updates.updatedOnServer, ...updates.newOnServer],
        );
      } catch (e) {
        result |= false;
      }
    }
    if (updates.newOnLocal.isNotEmpty) {
      result |= await insertMediaOnServer({...updates.newOnLocal});
    }

    /* result |= await insertMediaOnServer({...updates.newOnLocal});
    result |= await updateMediaOnServer({...updates.updatedOnLocal});
    result |= await deleteMediaByIdOnServer(
      {...updates.deletedOnServer},
    ); */

    return result;
  }

  Future<bool> downloadFiles(MediaDownloader downloader) async {
    if (storeCache == null) return false;

    log('Starting file download');
    {
      var previewsPending = await storeCache!.checkDBForPreviewDownloadPending;
      var mediaPending = await storeCache!.checkDBForMediaDownloadPending;

      while (previewsPending.isNotEmpty && mediaPending.isNotEmpty) {
        final currTasks = await triggerBatchDownload(
          downloader,
          previewsPending,
          mediaPending,
        );
        log('waiting for the downloads to complete');
        await Future.wait(currTasks.map((e) => e.completer.future));
        runningTasks.removeWhere((e) => e.completer.isCompleted);
        previewsPending = await storeCache!.checkDBForPreviewDownloadPending;
        mediaPending = await storeCache!.checkDBForMediaDownloadPending;
        log('Recheck DB for now items');
      }
    }
    log('nothing to download, Exit.');
    return true;
  }

  Future<void> abortDownloads() async {
    if (runningTasks.isNotEmpty) {
      log('Cancelling ${runningTasks.length} pending downloads');
      for (final t in runningTasks) {
        await downloader.cancel(t.task.taskId);
      }
      await Future.wait(runningTasks.map((e) => e.completer.future));
      runningTasks.clear();
      log('Cancelled all tasks');
      return;
    }
    log('no download is in progress to cancel');
  }

  Future<List<TaskCompleter>> triggerBatchDownload(
    MediaDownloader downloader,
    List<CLMedia> previewsPending,
    List<CLMedia> mediaPending,
  ) async {
    log('trigger download for ${previewsPending.length} previews');
    final currentTasks = <TaskCompleter>[];
    for (final media in previewsPending) {
      final instance = await downloader.downloadPreview(media);
      if (instance != null) {
        runningTasks.add(instance);
        currentTasks.add(instance);
      }
    }
    log('trigger download for ${mediaPending.length} medias');
    for (final media in mediaPending) {
      final instance = await downloader.downloadMedia(media);
      if (instance != null) {
        runningTasks.add(instance);
        currentTasks.add(instance);
      }
    }
    return currentTasks;
  }

  @override
  void dispose() {
    if (mediaDownloader != null) {
      abortDownloads();
    }
    super.dispose();
  }
}

final activeServerProvider =
    StateNotifierProvider<ActiveServerNotifier, bool>((ref) {
  final directories = ref.watch(deviceDirectoriesProvider.future);
  final downloader = ref.watch(downloaderProvider);
  final registerredServer = ref.watch(registeredServerProvider);
  final storeCache = ref.watch(storeCacheProvider);
  final workOffline = ref.watch(workingOfflineProvider);
  final onlineStatus = ref.watch(serverOnlineStatusProvider);

  final notifier = ActiveServerNotifier(
    ref: ref,
    storeCache: storeCache.whenOrNull(data: (data) => data),
    directoriesFuture: directories,
    downloader: downloader,
    server: (workOffline || !onlineStatus)
        ? null
        : storeCache.whenOrNull(data: (data) => registerredServer),
  );

  return notifier;
});
