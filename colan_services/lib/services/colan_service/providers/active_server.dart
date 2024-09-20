import 'dart:async';
import 'dart:developer' as dev;

import 'package:colan_services/internal/extensions/ext_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../storage_service/models/file_system/models/cl_directories.dart';
import '../../storage_service/providers/directories.dart';
import '../../store_service/providers/store.dart';
import '../../store_service/providers/store_cache.dart';
import '../../store_service/providers/sync_in_progress.dart';
import '../models/cl_server.dart';
import '../models/downloader.dart';
import '../models/media_downloader.dart';
import 'downloader_provider.dart';
import 'online_status.dart';
import 'registerred_server.dart';
import 'working_offline.dart';

class ActiveServerNotifier extends StateNotifier<CLServer?> {
  ActiveServerNotifier({
    required this.ref,
    required this.directoriesFuture,
    required this.storeFuture,
    required this.downloader,
    CLServer? server,
  }) : super(server) {
    _initialize();
  }
  final Ref ref;
  final Future<CLDirectories> directoriesFuture;
  final Future<Store> storeFuture;
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
    if (state != null) {
      mediaDownloader = MediaDownloader(
        downloader: downloader,
        server: state!,
        store: await storeFuture,
        directories: await directoriesFuture,
        onDone: (media) async {
          await ref.read(storeCacheProvider.notifier).refreshMedia(media);
        },
      );
      log('Media Downloader initialized for server $state');

      unawaited(sync());
    }
  }

  Future<bool?> sync() async {
    if (state == null) return false;
    final syncInPorgress = ref.read(syncStatusProvider);
    if (!syncInPorgress) {
      ref.read(syncStatusProvider.notifier).state = true;
      {
        final store = await storeFuture;
        // Upload logic here
        unawaited(
          state!.downloadMediaInfo(store).then((mapList) async {
            final updates = await store.analyseChanges(mapList);
            final result = await updateChanges(updates);

            if (result && mediaDownloader != null) {
              unawaited(
                downloadFiles(mediaDownloader!).then(
                  (_) => ref.read(syncStatusProvider.notifier).state = false,
                ),
              );
            } else {
              log('Sync ignored; either its not required or '
                  ' downloader not available');
              ref.read(syncStatusProvider.notifier).state = false;
            }
          }),
        );
        return true;
      }
    }
    return false;
  }

  Future<bool> deleteMediaByIdOnLocal(Set<int> serverUIDs2Delete) async {
    final store = await storeFuture;
    final idList = <int>{};
    for (final serverUID in serverUIDs2Delete) {
      final m = await store.getMediaByServerUID(serverUID);
      if (m != null) {
        idList.add(m.id!);
      }
    }

    return ref
        .read(storeCacheProvider.notifier)
        .permanentlyDeleteMediaMultiple(idList);
  }

  Future<bool> insertMediaOnLocal(Set<CLMedia> mediaSet) async {
    final store = await storeFuture;
    for (final m in mediaSet) {
      await store.upsertMedia(m);
    }
    await ref.read(storeCacheProvider.notifier).onRefresh();
    return true;
  }

  Future<bool> updateMediaOnLocal(Set<TrackedMedia> mediaSet) async {
    final store = await storeFuture;
    for (final m in mediaSet) {
      if (m.current.md5String != m.update.md5String) {
        await store.upsertMedia(
          m.update.copyWith(isPreviewCached: false, isMediaCached: false),
        );
        // TODO: delete files from m.current
      } else {
        await store.upsertMedia(m.update);
      }
    }
    await ref.read(storeCacheProvider.notifier).onRefresh();
    return false;
  }

  Future<bool> insertMediaOnServer(Set<CLMedia> mediaSet) async {
    return false;
  }

  Future<bool> updateMediaOnServer(Set<TrackedMedia> mediaSet) async {
    return false;
  }

  Future<bool> deleteMediaByIdOnServer(Set<int> serverUIDs) async {
    return false;
  }

  Future<bool> updateChanges(MediaUpdatesFromServer updates) async {
    var result = await deleteMediaByIdOnLocal({...updates.deletedOnServer});
    result |= await insertMediaOnLocal({...updates.newOnServer});
    result |= await updateMediaOnLocal({...updates.updatedOnServer});

    result |= await insertMediaOnServer({...updates.newOnLocal});
    result |= await updateMediaOnServer({...updates.updatedOnLocal});
    result |= await deleteMediaByIdOnServer({...updates.deletedOnServer});

    return result;
  }

  Future<void> downloadFiles(MediaDownloader downloader) async {
    final store = await storeFuture;

    log('Starting file download');
    {
      var previewsPending = await store.checkDBForPreviewDownloadPending;
      var mediaPending = await store.checkDBForMediaDownloadPending;

      while (previewsPending.isNotEmpty && mediaPending.isNotEmpty) {
        final currTasks = await triggerBatchDownload(
          downloader,
          previewsPending,
          mediaPending,
        );
        log('waiting for the downloads to complete');
        await Future.wait(currTasks.map((e) => e.completer.future));
        runningTasks.removeWhere((e) => e.completer.isCompleted);
        previewsPending = await store.checkDBForPreviewDownloadPending;
        mediaPending = await store.checkDBForMediaDownloadPending;
        log('Recheck DB for now items');
      }
    }
    log('nothing to download, Exit.');
  }

  Future<void> abortDownloads(MediaDownloader mediaDownloader) async {
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
      abortDownloads(mediaDownloader!);
    }
    super.dispose();
  }
}

final activeServerProvider =
    StateNotifierProvider<ActiveServerNotifier, CLServer?>((ref) {
  final store = ref.watch(storeProvider.future);
  final directories = ref.watch(deviceDirectoriesProvider.future);
  final downloader = ref.watch(downloaderProvider);
  final registerredServer = ref.watch(registeredServerProvider);
  final workOffline = ref.watch(workingOfflineProvider);
  final onlineStatus = ref.watch(serverOnlineStatusProvider);
  final notifier = ActiveServerNotifier(
    ref: ref,
    storeFuture: store,
    directoriesFuture: directories,
    downloader: downloader,
    server: workOffline || (!onlineStatus) ? null : registerredServer,
  );

  return notifier;
});
