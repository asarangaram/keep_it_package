import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:colan_services/internal/extensions/list.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../../internal/extensions/ext_cl_media.dart';
import '../../colan_service/models/cl_server.dart';
import '../../colan_service/providers/downloader.dart';
import '../../storage_service/models/file_system/models/cl_directories.dart';

class MediaDownloader extends Downloader {
  MediaDownloader({
    required this.store,
    required this.server,
    required this.directories,
    this.onDone,
  });

  final Store store;
  final CLDirectories directories;
  final CLServer server;
  final Future<void> Function(CLMedia media)? onDone;
  bool isDownloading = false;

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

  Future<void> downloadFiles() async {
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
        final pendingTasks = <Completer<void>>[];
        log('trigger download for ${previewsPending.length} previews');
        for (final media in previewsPending) {
          if (File(_getPreviewAbsolutePath(media)).existsSync()) {
            await _markPreviewAsDownloaded(media);
          } else {
            pendingTasks.add(_startPreviewDownload(media, 'PreviewFile'));
          }
        }
        log('trigger download for ${mediaPending.length} medias');
        for (final media in mediaPending) {
          if (File(_getMediaAbsolutePath(media)).existsSync()) {
            await _markMediaAsDownloaded(media);
          } else {
            pendingTasks.add(_startMediaDownload(media, 'MediaFiles'));
          }
        }
        log('waiting for the downloads to complete');
        await Future.wait(pendingTasks.map((e) => e.future));
        previewsPending = await _checkDBForPreviewDownloadPending;
        mediaPending = await _checkDBForMediaDownloadPending;
        log('Recheck DB for now items');
      }
    }
    log('nothing to download, Exit.');
    isDownloading = false;
  }

  String _getPreviewAbsolutePath(CLMedia media) => p.join(
        directories.thumbnail.pathString,
        media.previewFileName,
      );

  String _getMediaAbsolutePath(CLMedia media) => p.join(
        directories.media.path.path,
        media.mediaFileName,
      );

  BaseDirectory get _previewBaseDirectory => BaseDirectory.applicationSupport;
  BaseDirectory get _mediaBaseDirectory => BaseDirectory.applicationSupport;

  Future<List<CLMedia>> get _checkDBForPreviewDownloadPending async {
    final q = store.getQuery(
      DBQueries.previewDownloadPending,
    ) as StoreQuery<CLMedia>;
    return (await store.readMultiple(q)).nonNullableList;
  }

  Future<List<CLMedia>> get _checkDBForMediaDownloadPending async {
    final q = store.getQuery(
      DBQueries.mediaDownloadPending,
    ) as StoreQuery<CLMedia>;
    return (await store.readMultiple(q)).nonNullableList;
  }

  Future<void> _markPreviewAsDownloaded(CLMedia media) async {
    final mediaInDB = await store.updateMediaFromMap({
      'id': media.id,
      'previewLog': null,
      'isPreviewCached': true,
    });
    if (mediaInDB != null) {
      await onDone?.call(mediaInDB);
    }
  }

  Future<void> _markMediaAsDownloaded(CLMedia media) async {
    final mediaInDB = await store.updateMediaFromMap({
      'id': media.id,
      'mediaLog': null,
      'isMediaCached': true,
      'isMediaOriginal': true,
    });
    if (mediaInDB != null) {
      await onDone?.call(mediaInDB);
    }
  }

  Completer<void> _startPreviewDownload(
    CLMedia media,
    String group,
  ) {
    final completer = Completer<void>();
    enqueue(
      url: server.getEndpointURI(media.previewEndPoint!).toString(),
      baseDirectory: _previewBaseDirectory,
      directory: directories.thumbnail.name,
      filename: media.previewFileName,
      group: group,
      onDone: ({errorLog}) async {
        final mediaInDB = await store.updateMediaFromMap({
          'id': media.id,
          'previewLog': errorLog,
          'isPreviewCached': errorLog == null,
        });
        if (mediaInDB != null) {
          await onDone?.call(mediaInDB);
        }
        completer.complete();
      },
    );
    return completer;
  }

  Completer<void> _startMediaDownload(
    CLMedia media,
    String group,
  ) {
    final completer = Completer<void>();
    enqueue(
      url: server.getEndpointURI(media.mediaEndPoint!).toString(),
      baseDirectory: _mediaBaseDirectory,
      directory: directories.media.name,
      filename: media.mediaFileName,
      group: group,
      onDone: ({errorLog}) async {
        final mediaInDB = await store.updateMediaFromMap({
          'id': media.id,
          'mediaLog': errorLog,
          'isMediaCached': errorLog == null,
          'isMediaOriginal': errorLog == null && media.mustDownloadOriginal,
        });
        if (mediaInDB != null) {
          await onDone?.call(mediaInDB);
        }
        completer.complete();
      },
    );
    return completer;
  }
}
