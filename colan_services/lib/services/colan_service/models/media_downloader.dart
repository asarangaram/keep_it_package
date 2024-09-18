import 'dart:async';
import 'dart:developer' as dev;
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import 'package:store/store.dart';

import '../../../internal/extensions/ext_cl_media.dart';
import '../../colan_service/models/cl_server.dart';
import '../../storage_service/models/file_system/models/cl_directories.dart';
import 'downloader.dart';

@immutable
class TaskCompleter {
  const TaskCompleter(this.task, this.completer);
  final Task task;
  final Completer<void> completer;
}

class MediaDownloader extends Downloader {
  MediaDownloader(
    super.onStatusUpdate, {
    required this.store,
    required this.server,
    required this.directories,
    this.onDone,
  });

  final Store store;
  final CLDirectories directories;
  final CLServer server;
  final Future<void> Function(CLMedia media)? onDone;

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

  Future<TaskCompleter?> downloadPreview(CLMedia media) async {
    if (File(_getPreviewAbsolutePath(media)).existsSync()) {
      await _markPreviewAsDownloaded(media);
      return null;
    } else {
      return _startPreviewDownload(media, 'PreviewFile');
    }
  }

  Future<TaskCompleter?> downloadMedia(CLMedia media) async {
    if (File(_getMediaAbsolutePath(media)).existsSync()) {
      await _markMediaAsDownloaded(media);
      return null;
    } else {
      return _startMediaDownload(media, 'MediaFiles');
    }
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

  Future<TaskCompleter> _startPreviewDownload(
    CLMedia media,
    String group,
  ) async {
    final completer = Completer<Task>();
    final task = await enqueue(
      url: server.getEndpointURI(media.previewEndPoint!).toString(),
      baseDirectory: _previewBaseDirectory,
      directory: directories.thumbnail.name,
      filename: media.previewFileName,
      group: group,
      onDone: (task, {errorLog}) async {
        final mediaInDB = await store.updateMediaFromMap({
          'id': media.id,
          'previewLog': errorLog,
          'isPreviewCached': errorLog == null,
        });
        if (mediaInDB != null) {
          await onDone?.call(mediaInDB);
        }
        completer.complete(task);
      },
    );
    return TaskCompleter(task, completer);
  }

  Future<TaskCompleter> _startMediaDownload(
    CLMedia media,
    String group,
  ) async {
    final completer = Completer<Task>();
    final task = await enqueue(
      url: server.getEndpointURI(media.mediaEndPoint!).toString(),
      baseDirectory: _mediaBaseDirectory,
      directory: directories.media.name,
      filename: media.mediaFileName,
      group: group,
      onDone: (task, {errorLog}) async {
        final mediaInDB = await store.updateMediaFromMap({
          'id': media.id,
          'mediaLog': errorLog,
          'isMediaCached': errorLog == null,
          'isMediaOriginal': errorLog == null && media.mustDownloadOriginal,
        });
        if (mediaInDB != null) {
          await onDone?.call(mediaInDB);
        }
        completer.complete(task);
      },
    );
    return TaskCompleter(task, completer);
  }
}
