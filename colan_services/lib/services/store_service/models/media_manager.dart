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
class MediaManager {
  const MediaManager({
    required this.media,
    required this.appSettings,
    required this.localInfo,
    required this.downloadSettings,
    required this.server,
    required this.store,
  });
  final CLMedia media;
  final MediaLocalInfo localInfo;
  final AppSettings appSettings;
  final DownloadSettings downloadSettings;
  final CLServer? server;
  final Store store;

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

  Future<CLMedia> replaceMedia(
    CLMedia originalMedia,
    String outFile,
  ) async {
    final md5String = await File(outFile).checksum;
    final updatedMedia = originalMedia
        .copyWith(
          name: path_handler.basename(outFile),
          md5String: md5String,
          fExt: path_handler.extension(outFile),
        )
        .removePin();

    final mediaFromDB = await store.upsertMedia(
      updatedMedia,
    );
    if (mediaFromDB != null) {
      File(outFile)
        ..copySync(mediaFromDB.mediaFileURI(appSettings).path)
        ..deleteSync();
    }

    return mediaFromDB ?? originalMedia;
  }

  Future<CLMedia> cloneAndReplaceMedia(
    CLMedia originalMedia,
    String outFile,
  ) async {
    final md5String = await File(outFile).checksum;
    final CLMedia updatedMedia;
    updatedMedia = originalMedia
        .copyWith(
          name: path_handler.basename(outFile),
          md5String: md5String,
        )
        .removePin();

    final mediaFromDB = await store.upsertMedia(
      updatedMedia.removeId(),
    );
    if (mediaFromDB != null) {
      File(outFile)
        ..copySync(mediaFromDB.mediaFileURI(appSettings).path)
        ..deleteSync();
    }

    return mediaFromDB ?? originalMedia;
  }

  MediaManager copyWith({
    CLMedia? media,
    MediaLocalInfo? localInfo,
    AppSettings? appSettings,
    DownloadSettings? downloadSettings,
    CLServer? server,
    Store? store,
  }) {
    return MediaManager(
      media: media ?? this.media,
      localInfo: localInfo ?? this.localInfo,
      appSettings: appSettings ?? this.appSettings,
      downloadSettings: downloadSettings ?? this.downloadSettings,
      server: server ?? this.server,
      store: store ?? this.store,
    );
  }

  @override
  String toString() {
    return 'MediaManager(media: $media, localInfo: $localInfo, appSettings: $appSettings, downloadSettings: $downloadSettings, server: $server, store: $store)';
  }

  @override
  bool operator ==(covariant MediaManager other) {
    if (identical(this, other)) return true;

    return other.media == media &&
        other.localInfo == localInfo &&
        other.appSettings == appSettings &&
        other.downloadSettings == downloadSettings &&
        other.server == server &&
        other.store == store;
  }

  @override
  int get hashCode {
    return media.hashCode ^
        localInfo.hashCode ^
        appSettings.hashCode ^
        downloadSettings.hashCode ^
        server.hashCode ^
        store.hashCode;
  }
}
