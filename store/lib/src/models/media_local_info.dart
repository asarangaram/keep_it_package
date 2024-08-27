// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';

@immutable
class MediaLocalInfo {
  const MediaLocalInfo({
    required this.id,
    required this.isPreviewCached,
    required this.isMediaCached,
    required this.isMediaOriginal,
    required this.isEdited,
    required this.haveItOffline,
    required this.mustDownloadOriginal,
    required this.fileExtension,
    this.previewError,
    this.mediaError,
    this.serverUID,
  });

  factory MediaLocalInfo.fromMap(Map<String, dynamic> map) {
    return MediaLocalInfo(
      id: map['id'] as int,
      isPreviewCached: map['isPreviewCached'] as bool,
      isMediaCached: map['isMediaCached'] as bool,
      previewError:
          map['previewError'] != null ? map['previewError'] as String : null,
      mediaError:
          map['mediaError'] != null ? map['mediaError'] as String : null,
      isMediaOriginal: map['isMediaOriginal'] as bool,
      serverUID: map['serverUID'] != null ? map['serverUID'] as int : null,
      isEdited: map['isEdited'] as bool,
      haveItOffline: map['haveItOffline'] as bool,
      mustDownloadOriginal: map['mustDownloadOriginal'] as bool,
      fileExtension: map['fileExtension'] as String,
    );
  }

  factory MediaLocalInfo.fromJson(String source) =>
      MediaLocalInfo.fromMap(json.decode(source) as Map<String, dynamic>);
  final int id;
  final bool isPreviewCached;
  final bool isMediaCached;
  final String? previewError;
  final String? mediaError;
  final bool isMediaOriginal;
  final int? serverUID;
  final bool isEdited;
  final bool haveItOffline;
  final bool mustDownloadOriginal;
  final String fileExtension;

  MediaLocalInfo copyWith({
    int? id,
    bool? isPreviewCached,
    bool? isMediaCached,
    String? previewError,
    String? mediaError,
    bool? isMediaOriginal,
    int? serverUID,
    bool? isEdited,
    bool? haveItOffline,
    bool? mustDownloadOriginal,
    String? fileExtension,
  }) {
    return MediaLocalInfo(
      id: id ?? this.id,
      isPreviewCached: isPreviewCached ?? this.isPreviewCached,
      isMediaCached: isMediaCached ?? this.isMediaCached,
      previewError: previewError ?? this.previewError,
      mediaError: mediaError ?? this.mediaError,
      isMediaOriginal: isMediaOriginal ?? this.isMediaOriginal,
      serverUID: serverUID ?? this.serverUID,
      isEdited: isEdited ?? this.isEdited,
      haveItOffline: haveItOffline ?? this.haveItOffline,
      mustDownloadOriginal: mustDownloadOriginal ?? this.mustDownloadOriginal,
      fileExtension: fileExtension ?? this.fileExtension,
    );
  }

  @override
  String toString() {
    return 'MediaCache(id: $id, isPreviewCached: $isPreviewCached, isMediaCached: $isMediaCached, previewError: $previewError, mediaError: $mediaError, isMediaOriginal: $isMediaOriginal, serverUID: $serverUID, isEdited: $isEdited, haveItOffline: $haveItOffline, mustDownloadOriginal: $mustDownloadOriginal, fileExtension: $fileExtension)';
  }

  @override
  bool operator ==(covariant MediaLocalInfo other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.isPreviewCached == isPreviewCached &&
        other.isMediaCached == isMediaCached &&
        other.previewError == previewError &&
        other.mediaError == mediaError &&
        other.isMediaOriginal == isMediaOriginal &&
        other.serverUID == serverUID &&
        other.isEdited == isEdited &&
        other.haveItOffline == haveItOffline &&
        other.mustDownloadOriginal == mustDownloadOriginal &&
        other.fileExtension == fileExtension;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        isPreviewCached.hashCode ^
        isMediaCached.hashCode ^
        previewError.hashCode ^
        mediaError.hashCode ^
        isMediaOriginal.hashCode ^
        serverUID.hashCode ^
        isEdited.hashCode ^
        haveItOffline.hashCode ^
        mustDownloadOriginal.hashCode ^
        fileExtension.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'isPreviewCached': isPreviewCached,
      'isMediaCached': isMediaCached,
      'previewError': previewError,
      'mediaError': mediaError,
      'isMediaOriginal': isMediaOriginal,
      'serverUID': serverUID,
      'isEdited': isEdited,
      'haveItOffline': haveItOffline,
      'mustDownloadOriginal': mustDownloadOriginal,
      'fileExtension': fileExtension,
    };
  }

  String toJson() => json.encode(toMap());
}
