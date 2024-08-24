// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:background_downloader/background_downloader.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path/path.dart' as path_handler;
import 'package:store/store.dart';

import '../models/media_files_uri.dart';

extension StoreExtOnMediaServerInfo on MediaServerInfo {
  List<DownloadTask> pendingTasks({
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
    final Uri mediaUri;
    final Uri originalMediaUri;
    if (haveItOffline && mediaDownloaded) {
      // If original is available, provide original
      // else provide local copy
      if (isMediaOriginal) {
        originalMediaUri = Uri.file(
          path_handler.join(
            baseDirectory,
            mediaSubDirectory,
            originalName,
          ),
        );
        mediaUri = originalMediaUri;
      } else {
        mediaUri = Uri.file(
          path_handler.join(
            baseDirectory,
            mediaSubDirectory,
            mediaName,
          ),
        );
        originalMediaUri = Uri.parse(onGetURI(originalURL));
      }
    } else {
      mediaUri = Uri.parse(onGetURI(mediaURL));
      originalMediaUri = Uri.parse(onGetURI(originalURL));
    }

    return MediaFilesUri(
      previewPath: AsyncValue.data(previewUri),
      mediaPath: AsyncValue.data(mediaUri),
      originalMediaPath: AsyncValue.data(originalMediaUri),
    );
  }
}
