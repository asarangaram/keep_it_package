// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';

@immutable
class MediaServerInfo {
  const MediaServerInfo({
    required this.id,
    required this.serverUID,
    required this.haveItOffline,
    required this.mustDownloadOriginal,
    required this.previewDownloaded,
    required this.mediaDownloaded,
    required this.isOriginal,
    required this.locallyModified,
  });
  final int id;
  final int serverUID;
  final int haveItOffline;
  final int mustDownloadOriginal;
  final int previewDownloaded;
  final int mediaDownloaded;
  final int isOriginal;
  final int locallyModified;

  MediaServerInfo copyWith({
    int? id,
    int? serverUID,
    int? haveItOffline,
    int? mustDownloadOriginal,
    int? previewDownloaded,
    int? mediaDownloaded,
    int? isOriginal,
    int? locallyModified,
  }) {
    return MediaServerInfo(
      id: id ?? this.id,
      serverUID: serverUID ?? this.serverUID,
      haveItOffline: haveItOffline ?? this.haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal ?? this.mustDownloadOriginal,
      previewDownloaded: previewDownloaded ?? this.previewDownloaded,
      mediaDownloaded: mediaDownloaded ?? this.mediaDownloaded,
      isOriginal: isOriginal ?? this.isOriginal,
      locallyModified: locallyModified ?? this.locallyModified,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'serverUID': serverUID,
      'haveItOffline': haveItOffline,
      'mustDownloadOriginal': mustDownloadOriginal,
      'previewDownloaded': previewDownloaded,
      'mediaDownloaded': mediaDownloaded,
      'isOriginal': isOriginal,
      'locallyModified': locallyModified,
    };
  }

  factory MediaServerInfo.fromMap(Map<String, dynamic> map) {
    return MediaServerInfo(
      id: map['id'] as int,
      serverUID: map['serverUID'] as int,
      haveItOffline: map['haveItOffline'] as int,
      mustDownloadOriginal: map['mustDownloadOriginal'] as int,
      previewDownloaded: map['previewDownloaded'] as int,
      mediaDownloaded: map['mediaDownloaded'] as int,
      isOriginal: map['isOriginal'] as int,
      locallyModified: map['locallyModified'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory MediaServerInfo.fromJson(String source) =>
      MediaServerInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'MediaServerInfo(id: $id, serverUID: $serverUID, haveItOffline: $haveItOffline, mustDownloadOriginal: $mustDownloadOriginal, previewDownloaded: $previewDownloaded, mediaDownloaded: $mediaDownloaded, isOriginal: $isOriginal, locallyModified: $locallyModified)';
  }

  @override
  bool operator ==(covariant MediaServerInfo other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.serverUID == serverUID &&
        other.haveItOffline == haveItOffline &&
        other.mustDownloadOriginal == mustDownloadOriginal &&
        other.previewDownloaded == previewDownloaded &&
        other.mediaDownloaded == mediaDownloaded &&
        other.isOriginal == isOriginal &&
        other.locallyModified == locallyModified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        serverUID.hashCode ^
        haveItOffline.hashCode ^
        mustDownloadOriginal.hashCode ^
        previewDownloaded.hashCode ^
        mediaDownloaded.hashCode ^
        isOriginal.hashCode ^
        locallyModified.hashCode;
  }
}
