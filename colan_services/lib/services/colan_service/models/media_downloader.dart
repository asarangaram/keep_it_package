import 'dart:async';
import 'dart:convert';
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

class MediaDownloader {
  MediaDownloader({
    required this.server,
    required this.directories,
    required this.downloader,
    this.onDone,
  });

  final CLDirectories directories;
  final CLServer server;
  final Future<void> Function(Map<String, dynamic> map)? onDone;
  late final Downloader downloader;

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
    await onDone?.call({
      'id': media.id,
      'previewLog': null,
      'isPreviewCached': 1,
    });
  }

  Future<void> _markMediaAsDownloaded(CLMedia media) async {
    await onDone?.call({
      'id': media.id,
      'mediaLog': null,
      'isMediaCached': 1,
      'isMediaOriginal': 1,
    });
  }

  Future<TaskCompleter> _startPreviewDownload(
    CLMedia media,
    String group,
  ) async {
    final completer = Completer<Task>();
    final task = await downloader.enqueue(
      url: server.getEndpointURI(media.previewEndPoint!).toString(),
      baseDirectory: _previewBaseDirectory,
      directory: directories.thumbnail.name,
      filename: media.previewFileName,
      group: group,
      onDone: (task, {required status, errorLog}) async {
        await onDone?.call({
          'id': media.id,
          'previewLog': errorLog,
          'isPreviewCached': (errorLog == null) ? 1 : 0,
        });

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
    final task = await downloader.enqueue(
      url: server.getEndpointURI(media.mediaEndPoint!).toString(),
      baseDirectory: _mediaBaseDirectory,
      directory: directories.media.name,
      filename: media.mediaFileName,
      group: group,
      onDone: (task, {required status, errorLog}) async {
        await onDone?.call({
          'id': media.id,
          'mediaLog': errorLog,
          'isMediaCached': errorLog == null ? 1 : 0,
          'isMediaOriginal':
              (errorLog == null && media.mustDownloadOriginal) ? 1 : 0,
        });

        completer.complete(task);
      },
    );
    return TaskCompleter(task, completer);
  }

  Future<TaskCompleter> uploadMedia(
    CLMedia media,
    String group, {
    required Map<String, String> fields,
  }) async {
    final completer = Completer<Task>();
    final task = await downloader.enqueueUpload(
      url: server.getEndpointURI(media.mediaUploadEndPoint!).toString(),
      baseDirectory: _previewBaseDirectory,
      directory: directories.media.name,
      filename: media.mediaFileName,
      group: group,
      fields: fields,
      onDone: (task, {required status, errorLog}) async {
        if (errorLog == null && status.responseBody != null) {
          final map = jsonDecode(status.responseBody!) as Map<String, dynamic>;
          await onDone?.call({
            'id': media.id,
            ...map,
          });
        }

        completer.complete(task);
      },
    );
    return TaskCompleter(task, completer);
  }
}
