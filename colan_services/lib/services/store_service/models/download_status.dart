// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:background_downloader/background_downloader.dart';
import 'package:flutter/material.dart';
import 'package:store/store.dart';

@immutable
class DownloadStatus {
  const DownloadStatus({
    required this.serverUID,
    required this.ext,
    required this.haveItOffline,
    required this.mustDownloadOriginal,
    this.previewDownloaded = false,
    this.mediaDownloaded = false,
    this.isOriginal = false,
  });

  factory DownloadStatus.fromMap(Map<String, dynamic> map) {
    return DownloadStatus(
      serverUID: map['serverUID'] as int,
      ext: map['ext'] as String,
      previewDownloaded: map['previewDownloaded'] as bool,
      mediaDownloaded: map['mediaDownloaded'] as bool,
      isOriginal: map['isOriginal'] as bool,
      haveItOffline: map['haveItOffline'] as bool,
      mustDownloadOriginal: map['mustDownloadOriginal'] as bool,
    );
  }

  factory DownloadStatus.fromJson(String source) =>
      DownloadStatus.fromMap(json.decode(source) as Map<String, dynamic>);

  final int serverUID;
  final String ext;
  final bool previewDownloaded;
  final bool mediaDownloaded;
  final bool isOriginal;
  final bool haveItOffline;
  final bool mustDownloadOriginal;

  DownloadStatus copyWith({
    int? serverUID,
    String? ext,
    bool? previewDownloaded,
    bool? mediaDownloaded,
    bool? isOriginal,
    bool? haveItOffline,
    bool? mustDownloadOriginal,
  }) {
    return DownloadStatus(
      serverUID: serverUID ?? this.serverUID,
      ext: ext ?? this.ext,
      previewDownloaded: previewDownloaded ?? this.previewDownloaded,
      mediaDownloaded: mediaDownloaded ?? this.mediaDownloaded,
      isOriginal: isOriginal ?? this.isOriginal,
      haveItOffline: haveItOffline ?? this.haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal ?? this.mustDownloadOriginal,
    );
  }

  @override
  // ignore: lines_longer_than_80_chars
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'DownloadStatus(serverUID: $serverUID, ext: $ext, previewDownloaded: $previewDownloaded, mediaDownloaded: $mediaDownloaded, isOriginal: $isOriginal, haveItOffline: $haveItOffline, mustDownloadOriginal: $mustDownloadOriginal)';
  }

  @override
  bool operator ==(covariant DownloadStatus other) {
    if (identical(this, other)) return true;

    return other.serverUID == serverUID &&
        other.ext == ext &&
        other.previewDownloaded == previewDownloaded &&
        other.mediaDownloaded == mediaDownloaded &&
        other.isOriginal == isOriginal &&
        other.haveItOffline == haveItOffline &&
        other.mustDownloadOriginal == mustDownloadOriginal;
  }

  @override
  int get hashCode {
    return serverUID.hashCode ^
        ext.hashCode ^
        previewDownloaded.hashCode ^
        mediaDownloaded.hashCode ^
        isOriginal.hashCode ^
        haveItOffline.hashCode ^
        mustDownloadOriginal.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'serverUID': serverUID,
      'ext': ext,
      'previewDownloaded': previewDownloaded,
      'mediaDownloaded': mediaDownloaded,
      'isOriginal': isOriginal,
      'haveItOffline': haveItOffline,
      'mustDownloadOriginal': mustDownloadOriginal,
    };
  }

  String toJson() => json.encode(toMap());

  static DownloadStatus? readFrom(CLMedia media) {
    if (media.serverUID == null) return null;
    final map = (media.downloadStatus ??
        DownloadStatus(
          serverUID: media.serverUID!,
          ext: '.jpg', // TODO(anandas): Fix this
          haveItOffline: media.haveItOffline,
          mustDownloadOriginal: media.mustDownloadOriginal,
        ).toMap()) as Map<String, dynamic>;
    if (map.containsKey('ServerUID')) {
      if (map['serverUID'] != media.serverUID) {
        throw Exception('conflicting ServerUID');
      }
    } else {
      map['serverUID'] = media.serverUID;
    }

    return DownloadStatus.fromMap(map);
  }

  String get previewURL => '/media/$serverUID/download?dimension=256';
  String get mediaURL => '/media/$serverUID/download?dimension=256';
  String get originalURL => '/media/$serverUID/download?dimension=256';

  String get previewName => '${serverUID}_tn.$ext';
  String get mediaName => '$serverUID.$ext';
  String get originalName => '${serverUID}_org.$ext';

  List<DownloadTask> pendingTasks({
    required String mediaSubDirectory,
    required String Function(String path) onGetURI,
  }) {
    return [
      if (!previewDownloaded)
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

  void files2Delete() {}
}
