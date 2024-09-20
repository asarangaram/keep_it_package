import 'dart:async';
import 'dart:developer' as dev;

import 'package:colan_services/internal/extensions/ext_store.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../../internal/extensions/list.dart';
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

  bool isDownloading = false;

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

  final runningTasks = <TaskCompleter>[];

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

  Future<bool?> sync() async {
    // Upload logic here
    unawaited(
      downloadMetadata().then((result) {
        if (result && mediaDownloader != null) {
          downloadFiles(mediaDownloader!);
        } else {
          log('Sync ignored; either its not required or '
              ' downloader not available');
        }
      }),
    );
    return true;
  }

  Future<void> downloadFiles(MediaDownloader downloader) async {
    // Don't trigger multiple
    if (isDownloading) {
      log('ignore multiple requests');
      return;
    }
    isDownloading = true;
    log('Starting');
    {
      var previewsPending = await _checkDBForPreviewDownloadPending;
      var mediaPending = await _checkDBForMediaDownloadPending;

      while (previewsPending.isNotEmpty && mediaPending.isNotEmpty) {
        final currTasks = await triggerBatchDownload(
          downloader,
          previewsPending,
          mediaPending,
        );
        log('waiting for the downloads to complete');
        await Future.wait(currTasks.map((e) => e.completer.future));
        runningTasks.removeWhere((e) => e.completer.isCompleted);
        previewsPending = await _checkDBForPreviewDownloadPending;
        mediaPending = await _checkDBForMediaDownloadPending;
        log('Recheck DB for now items');
      }
    }
    log('nothing to download, Exit.');
    isDownloading = false;
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

  Future<List<CLMedia>> get _checkDBForPreviewDownloadPending async {
    final store = await storeFuture;
    final q = store.getQuery(
      DBQueries.previewDownloadPending,
    ) as StoreQuery<CLMedia>;
    return (await store.readMultiple(q)).nonNullableList;
  }

  Future<List<CLMedia>> get _checkDBForMediaDownloadPending async {
    final store = await storeFuture;
    final q = store.getQuery(
      DBQueries.mediaDownloadPending,
    ) as StoreQuery<CLMedia>;
    return (await store.readMultiple(q)).nonNullableList;
  }

  Future<bool> downloadMetadata() async {
    if (state != null) {
      final store = await storeFuture;
      final syncInPorgress = ref.read(syncStatusProvider);
      if (!syncInPorgress) {
        ref.read(syncStatusProvider.notifier).state = true;
        {
          final mediaMap = await state!.downloadMediaInfo();
          if (mediaMap != null) {
            await store.updateStoreFromMediaMapList(mediaMap);
          }
        }
        ref.read(syncStatusProvider.notifier).state = false;
        return true;
      }
    }
    return false;
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
