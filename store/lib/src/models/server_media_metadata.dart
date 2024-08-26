import 'dart:convert';

import 'package:meta/meta.dart';

@immutable
class ServerMediaMetadata {
  const ServerMediaMetadata({
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

  factory ServerMediaMetadata.fromMap(Map<String, dynamic> map) {
    return ServerMediaMetadata(
      id: map['mediaId'] as int,
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

  factory ServerMediaMetadata.fromJson(String source) =>
      ServerMediaMetadata.fromMap(
        json.decode(source) as Map<String, dynamic>,
      );
  final int id;
  final String fileExtension;

  final int serverUID;
  final bool haveItOffline;
  final bool mustDownloadOriginal;
  final bool previewDownloaded;
  final bool mediaDownloaded;
  final bool isMediaOriginal;
  final bool locallyModified;

  ServerMediaMetadata copyWith({
    int? mediaId,
    String? fileExtension,
    int? serverUID,
    bool? haveItOffline,
    bool? mustDownloadOriginal,
    bool? previewDownloaded,
    bool? mediaDownloaded,
    bool? isMediaOriginal,
    bool? locallyModified,
  }) {
    return ServerMediaMetadata(
      id: mediaId ?? id,
      fileExtension: fileExtension ?? this.fileExtension,
      serverUID: serverUID ?? this.serverUID,
      haveItOffline: haveItOffline ?? this.haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal ?? this.mustDownloadOriginal,
      previewDownloaded: previewDownloaded ?? this.previewDownloaded,
      mediaDownloaded: mediaDownloaded ?? this.mediaDownloaded,
      isMediaOriginal: isMediaOriginal ?? this.isMediaOriginal,
      locallyModified: locallyModified ?? this.locallyModified,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'ServerMediaAbsolutePaths(mediaId: $id, fileExtension: $fileExtension, serverUID: $serverUID, haveItOffline: $haveItOffline, mustDownloadOriginal: $mustDownloadOriginal, previewDownloaded: $previewDownloaded, mediaDownloaded: $mediaDownloaded, isMediaOriginal: $isMediaOriginal, locallyModified: $locallyModified)';
  }

  @override
  bool operator ==(covariant ServerMediaMetadata other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.fileExtension == fileExtension &&
        other.serverUID == serverUID &&
        other.haveItOffline == haveItOffline &&
        other.mustDownloadOriginal == mustDownloadOriginal &&
        other.previewDownloaded == previewDownloaded &&
        other.mediaDownloaded == mediaDownloaded &&
        other.isMediaOriginal == isMediaOriginal &&
        other.locallyModified == locallyModified;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        fileExtension.hashCode ^
        serverUID.hashCode ^
        haveItOffline.hashCode ^
        mustDownloadOriginal.hashCode ^
        previewDownloaded.hashCode ^
        mediaDownloaded.hashCode ^
        isMediaOriginal.hashCode ^
        locallyModified.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'mediaId': id,
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

  String toJson() => json.encode(toMap());
}
