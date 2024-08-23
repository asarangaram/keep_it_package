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
    required this.isMediaOriginal,
    required this.locallyModified,
    required this.fileExtension,
  });
  final int id;
  final int serverUID;
  final bool haveItOffline;
  final bool mustDownloadOriginal;
  final bool previewDownloaded;
  final bool mediaDownloaded;
  final bool isMediaOriginal;
  final bool locallyModified;
  final String fileExtension;

  MediaServerInfo copyWith({
    int? id,
    int? serverUID,
    bool? haveItOffline,
    bool? mustDownloadOriginal,
    bool? previewDownloaded,
    bool? mediaDownloaded,
    bool? isMediaOriginal,
    bool? locallyModified,
    String? fileExtension,
  }) {
    return MediaServerInfo(
      id: id ?? this.id,
      serverUID: serverUID ?? this.serverUID,
      haveItOffline: haveItOffline ?? this.haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal ?? this.mustDownloadOriginal,
      previewDownloaded: previewDownloaded ?? this.previewDownloaded,
      mediaDownloaded: mediaDownloaded ?? this.mediaDownloaded,
      isMediaOriginal: isMediaOriginal ?? this.isMediaOriginal,
      locallyModified: locallyModified ?? this.locallyModified,
      fileExtension: fileExtension ?? this.fileExtension,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'serverUID': serverUID,
      'haveItOffline': haveItOffline ? 1 : 0,
      'mustDownloadOriginal': mustDownloadOriginal ? 1 : 0,
      'previewDownloaded': previewDownloaded ? 1 : 0,
      'mediaDownloaded': mediaDownloaded ? 1 : 0,
      'isMediaOriginal': isMediaOriginal ? 1 : 0,
      'locallyModified': locallyModified ? 1 : 0,
      'fileExtension': fileExtension,
    };
  }

  factory MediaServerInfo.fromMap(Map<String, dynamic> map) {
    return MediaServerInfo(
      id: map['id'] as int,
      serverUID: map['serverUID'] as int,
      haveItOffline: (map['haveItOffline'] as int) != 0,
      mustDownloadOriginal: (map['mustDownloadOriginal'] as int) != 0,
      previewDownloaded: (map['previewDownloaded'] as int) != 0,
      mediaDownloaded: (map['mediaDownloaded'] as int) != 0,
      isMediaOriginal: (map['isMediaOriginal'] as int) != 0,
      locallyModified: (map['locallyModified'] as int) != 0,
      fileExtension: map['fileExtension'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory MediaServerInfo.fromJson(String source) =>
      MediaServerInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'MediaServerInfo(id: $id, serverUID: $serverUID, haveItOffline: $haveItOffline, mustDownloadOriginal: $mustDownloadOriginal, previewDownloaded: $previewDownloaded, mediaDownloaded: $mediaDownloaded, isMediaOriginal: $isMediaOriginal, locallyModified: $locallyModified, fileExtension: $fileExtension)';
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
        other.isMediaOriginal == isMediaOriginal &&
        other.locallyModified == locallyModified &&
        other.fileExtension == fileExtension;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        serverUID.hashCode ^
        haveItOffline.hashCode ^
        mustDownloadOriginal.hashCode ^
        previewDownloaded.hashCode ^
        mediaDownloaded.hashCode ^
        isMediaOriginal.hashCode ^
        locallyModified.hashCode ^
        fileExtension.hashCode;
  }

  String get previewURL => '/media/$serverUID/download?dimension=256';
  String get mediaURL => '/media/$serverUID/download?dimension=256';
  String get originalURL => '/media/$serverUID/download?dimension=256';

  // TODO: Find extension
  String get previewName => '${serverUID}_tn$fileExtension';
  String get mediaName => '$serverUID$fileExtension';
  String get originalName => '${serverUID}_org$fileExtension';
}
