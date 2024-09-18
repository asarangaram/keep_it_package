import 'dart:async';
import 'dart:developer' as dev;

import 'package:colan_services/internal/extensions/list.dart';
import 'package:colan_services/services/colan_service/models/media_downloader.dart';
import 'package:colan_services/services/colan_service/providers/servers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:store/store.dart';

import '../../storage_service/models/file_system/models/cl_directories.dart';
import '../../storage_service/providers/directories.dart';
import '../../store_service/providers/store.dart';
import '../models/cl_server.dart';
import '../models/downloader_status.dart';

class CLServerNotifier extends StateNotifier<CLServer?> {
  CLServerNotifier({
    required this.ref,
    required this.directoriesFuture,
    required this.storeFuture,
    CLServer? server,
  }) : super(server) {
    _initialize();
  }
  Ref ref;
  Future<CLDirectories> directoriesFuture;
  Future<Store> storeFuture;
  MediaDownloader? downloader;

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
      name: 'Online Service: Media Downloader',
    );
  }

  bool isDownloading = false;

  Future<void> _initialize() async {
    if (state != null) {
      downloader = MediaDownloader(
        (status) {
          ref.read(downloaderStatusProvider.notifier).state = status;
        },
        server: state!,
        store: await storeFuture,
        directories: await directoriesFuture,
      );
      unawaited(downloadFiles(downloader!));
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

  Future<void> abortDownloads(MediaDownloader downloader) async {
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

  @override
  void dispose() {
    if (downloader != null) {
      abortDownloads(downloader!);
    }
    super.dispose();
  }
}

final clServerNotifierProvider =
    StateNotifierProvider<CLServerNotifier, CLServer?>((ref) {
  final store = ref.watch(rawStoreProvider.future);
  final directories = ref.watch(deviceDirectoriesProvider.future);
  final servers = ref.watch(serversProvider);

  final notifier = CLServerNotifier(
    ref: ref,
    server: servers.myServer,
    storeFuture: store,
    directoriesFuture: directories,
  );
  ref.onDispose(notifier.dispose);
  return notifier;
});

final downloaderStatusProvider = StateProvider<DownloaderStatus>((ref) {
  return const DownloaderStatus();
});
