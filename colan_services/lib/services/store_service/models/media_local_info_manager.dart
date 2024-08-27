// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'dart:io';

import 'package:background_downloader/background_downloader.dart';
import 'package:colan_services/services/store_service/extensions/cl_media.dart';
import 'package:device_resources/device_resources.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path_handler;
import 'package:path/path.dart';
import 'package:store/store.dart';

@immutable
class MediaLocalInfoManager {
  const MediaLocalInfoManager({
    required this.media,
    required this.appSettings,
    required this.localInfo,
    required this.downloadSettings,
    required this.server,
  });
  final CLMedia media;
  final MediaLocalInfo localInfo;
  final AppSettings appSettings;
  final DownloadSettings downloadSettings;
  final CLServer? server;

  Uri get previewFileURI => media.previewFileURI(appSettings);
  Uri get mediaFileURI => media.mediaFileURI(appSettings);

  Uri? getValidPreviewUri() {
    if (localInfo.previewError != null) {
      throw Exception(localInfo.previewError);
    }
    if (localInfo.isPreviewCached) {
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
    if (localInfo.isMediaCached) {
      if (!File(mediaFileURI.path).existsSync()) {
        // TODO(anandas):  Log here

        throw Exception('File is missing');
      }
      return mediaFileURI;
    }

    return (localInfo.mustDownloadOriginal ? originalURL : mediaURL);
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
          filename: basename(mediaFileURI.path),
          requiresWiFi: true,
          retries: 5,
          metaData: jsonEncode({'media': localInfo.id}),
        ),
    ];
  }
}
