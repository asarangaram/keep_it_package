// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:meta/meta.dart';

@immutable
class MediaStatus {
  const MediaStatus({
    required this.id,
    required this.isPreviewCached,
    required this.isMediaCached,
    required this.isMediaOriginal,
    required this.isEdited,
    required this.previewError,
    required this.mediaError,
    required this.serverUID,
  });

  factory MediaStatus.fromMap(Map<String, dynamic> map) {
    return MediaStatus(
      id: map['id'] as int,
      isPreviewCached: (map['isPreviewCached'] as int) != 0,
      isMediaCached: (map['isMediaCached'] as int) != 0,
      previewError:
          map['previewError'] != null ? map['previewError'] as String : null,
      mediaError:
          map['mediaError'] != null ? map['mediaError'] as String : null,
      isMediaOriginal: (map['isMediaOriginal'] as int) != 0,
      serverUID: map['serverUID'] != null ? map['serverUID'] as int : null,
      isEdited: (map['isEdited'] as int) != 0,
    );
  }

  factory MediaStatus.fromJson(String source) =>
      MediaStatus.fromMap(json.decode(source) as Map<String, dynamic>);
  final int id;
  final bool isPreviewCached;
  final bool isMediaCached;
  final String? previewError;
  final String? mediaError;
  final bool isMediaOriginal;
  final int? serverUID;
  final bool isEdited;

  MediaStatus copyWith({
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
  }) {
    return MediaStatus(
      id: id ?? this.id,
      isPreviewCached: isPreviewCached ?? this.isPreviewCached,
      isMediaCached: isMediaCached ?? this.isMediaCached,
      previewError: previewError ?? this.previewError,
      mediaError: mediaError ?? this.mediaError,
      isMediaOriginal: isMediaOriginal ?? this.isMediaOriginal,
      serverUID: serverUID ?? this.serverUID,
      isEdited: isEdited ?? this.isEdited,
    );
  }

  @override
  String toString() {
    // ignore: lines_longer_than_80_chars
    return 'MediaLocalInfo(id: $id, isPreviewCached: $isPreviewCached, isMediaCached: $isMediaCached, previewError: $previewError, mediaError: $mediaError, isMediaOriginal: $isMediaOriginal, serverUID: $serverUID, isEdited: $isEdited)';
  }

  @override
  bool operator ==(covariant MediaStatus other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.isPreviewCached == isPreviewCached &&
        other.isMediaCached == isMediaCached &&
        other.previewError == previewError &&
        other.mediaError == mediaError &&
        other.isMediaOriginal == isMediaOriginal &&
        other.serverUID == serverUID &&
        other.isEdited == isEdited;
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
        isEdited.hashCode;
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'isPreviewCached': isPreviewCached ? 1 : 0,
      'isMediaCached': isMediaCached ? 1 : 0,
      'previewError': previewError,
      'mediaError': mediaError,
      'isMediaOriginal': isMediaOriginal ? 1 : 0,
      'serverUID': serverUID,
      'isEdited': isEdited ? 1 : 0,
    };
  }

  String toJson() => json.encode(toMap());

  MediaStatus clearPreviewCache() {
    return MediaStatus(
      id: id,
      isPreviewCached: false,
      isMediaCached: isMediaCached,
      previewError: null,
      mediaError: mediaError,
      isMediaOriginal: isMediaOriginal,
      serverUID: serverUID,
      isEdited: isEdited,
    );
  }
}

class DefaultMediaStatus extends MediaStatus {
  const DefaultMediaStatus({
    required super.id,
    super.serverUID,
  }) : super(
          isPreviewCached: false,
          isMediaCached: true,
          isMediaOriginal: true,
          isEdited: false,
          previewError: null,
          mediaError: null,
        );
}
