// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_handler;
import 'package:path/path.dart';
import 'package:store/store.dart';

@immutable
class MediaLocalInfoManager {
  const MediaLocalInfoManager({
    required this.appSettings,
    required this.localInfo,
    required this.downloadSettings,
    required this.server,
  });

  final MediaLocalInfo localInfo;
  final AppSettings appSettings;
  final DownloadSettings downloadSettings;
  final CLServer? server;

  String get mediaFilename => '${localInfo.id}.${localInfo.fileExtension}';
  String get previewFilename => '${localInfo.id}.tn.${localInfo.fileExtension}';

  Uri returnValidPath(Uri p) {
    if (p.scheme != 'file') {
      throw Exception('Uri is not referrring to a file');
    }
    if (!File(p.path).parent.existsSync()) {
      File(p.path).parent.createSync(recursive: true);
    }
    return p;
  }

  Uri get previewFileURI {
    return returnValidPath(
      Uri.file(
        path_handler.join(
          appSettings.thumbnailDirectoryPath,
          previewFilename,
        ),
      ),
    );
  }

  Uri? getValidPreviewUri() {
    if (localInfo.previewError != null) {
      throw Exception(localInfo.previewError);
    }
    if (!localInfo.isPreviewCached) {
      if (!File(previewFileURI.path).existsSync()) {
        // TODO(anandas):  Log here

        throw Exception('File is missing');
      }
      return previewFileURI;
    }

    return previewURL;
  }

  Uri? getValidMediaUri() {
    if (localInfo.mediaError != null) {
      throw Exception(localInfo.mediaError);
    }
    if (!localInfo.isMediaCached) {
      if (!File(mediaURI.path).existsSync()) {
        // TODO(anandas):  Log here

        throw Exception('File is missing');
      }
      return previewFileURI;
    }

    return (localInfo.mustDownloadOriginal ? originalURL : mediaURL);
  }

  Uri get mediaURI {
    return returnValidPath(
      Uri.file(
        path_handler.join(
          appSettings.mediaDirectory.path,
          mediaFilename,
        ),
      ),
    );
  }

  Uri? get mediaURL => localInfo.serverUID == null
      ? null
      : server!.getEndpointURI('media/${localInfo.serverUID}/download/'
          'dim=${downloadSettings.previewDimension}');

  Uri? get originalURL => localInfo.serverUID == null
      ? null
      : server!.getEndpointURI('media/${localInfo.serverUID}/download');

  Uri? get previewURL => localInfo.serverUID == null
      ? null
      : server!.getEndpointURI('media/${localInfo.serverUID}/download/'
          'dim=${localInfo.id}/dim=${downloadSettings.downloadMediaDimension}');

  List<DownloadTask> pendingMediaDownloadTasks() {
    if (localInfo.serverUID == null || server == null) return [];
    assert(previewURL != null, "previewURL can't be null here");
    assert(mediaURL != null, "previewURL can't be null here");
    assert(originalURL != null, "previewURL can't be null here");

    return [
      if (!localInfo.isPreviewCached)
        DownloadTask(
          url: previewURL.toString(),
          filename: basename(previewFileURI.path),
          requiresWiFi: true,
          retries: 5,
          metaData: jsonEncode({'preview': localInfo.id}),
        ),
      if (localInfo.haveItOffline)
        DownloadTask(
          url: (localInfo.mustDownloadOriginal ? originalURL : mediaURL)!
              .toString(),
          filename: basename(mediaURI.path),
          requiresWiFi: true,
          retries: 5,
          metaData: jsonEncode({'media': localInfo.id}),
        ),
    ];
  }
}
