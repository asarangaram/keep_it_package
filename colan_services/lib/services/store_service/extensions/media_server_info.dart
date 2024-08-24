// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:background_downloader/background_downloader.dart';

import 'package:path/path.dart' as path_handler;
import 'package:store/store.dart';

import '../models/media_files_uri.dart';

extension StoreExtOnMediaServerInfo on MediaServerInfo {
  List<DownloadTask> pendingMediaDownloadTasks({
    required String mediaSubDirectory,
    required String Function(String path) onGetURI,
  }) {
    return [
      if (previewDownloaded)
        DownloadTask(
          url: onGetURI(previewURL),
          filename: previewName,
          directory: mediaSubDirectory,
          requiresWiFi: true,
          retries: 5,
          metaData: jsonEncode({'preview': serverUID}),
        ),
      if (haveItOffline && mustDownloadOriginal)
        DownloadTask(
          url: onGetURI(mediaURL),
          filename: mediaName,
          directory: mediaSubDirectory,
          requiresWiFi: true,
          retries: 5,
          metaData: jsonEncode({'media': serverUID}),
        ),
      if (haveItOffline && !mustDownloadOriginal)
        DownloadTask(
          url: onGetURI(originalURL),
          filename: originalName,
          directory: mediaSubDirectory,
          requiresWiFi: true,
          retries: 5,
          metaData: jsonEncode({'original': serverUID}),
        ),
    ];
  }

  List<String> files2Delete({required String mediaSubDirectory}) {
    return [
      if (haveItOffline && mustDownloadOriginal) mediaName,
      if (haveItOffline && !mustDownloadOriginal) originalName,
      if (!haveItOffline) ...[mediaName, originalName],
    ];
  }

  MediaFilesUri getMediaFilesUri({
    required String baseDirectory,
    required String mediaSubDirectory,
    required String Function(String path) onGetURI,
  }) {
    final previewUri = previewDownloaded
        ? Uri.file(
            path_handler.join(
              baseDirectory,
              mediaSubDirectory,
              previewName,
            ),
          )
        : Uri.parse(onGetURI(previewURL));
    if (haveItOffline && mediaDownloaded) {
      // If original is available, provide original
      // else provide local copy
      if (isMediaOriginal) {
      } else {}
    } else {}

    return MediaFilesUri(
      previewPath: previewUri,
      mediaPath: previewUri,
      originalMediaPath: previewUri,
    );
  }
}
